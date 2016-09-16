#!/bin/bash

if [ 'Msys' != `uname -o` ]; then
  echo Error! Should run in a MSYS2 environment!
  exit 1
fi

swd=$(readlink -f `dirname $BASH_SOURCE`)
envscript="$swd/env.sh"
source $envscript 'Msys-x86_64' || {
  echo "Failed to execute $envscript!"
  exit 1
}

plugindir=$deploydir/plugins
windeploy=`which windeployqt`
qmldir=$projdir

copy_mingw_deps() {
  local outdir=$1
  local exe=$exe_debug
  if [ ! -x $exe ]; then
    echo "Building a debug exe to be to extract its system deps..."
    proj_set_buildconf 'debug'
    proj_config && proj_build
    proj_set_buildconf 'release'
  fi
  local dlls=$(ldd $exe | grep "/mingw64" | sed 's,^.\+ \(/.*\.dll\).\+$,\1,gi')
  echo "## Copying mingw64 DLLs to $outdir..."
  cp -fv $dlls $outdir
}

copy_app_deps() {
  local outdir=$1
  echo "## Copying app deps DLLs to $outdir..."
  cp -fv \
    $exe_release \
    qt.conf $outdir
}

if [ ! -x $exe_release ]; then
  echo "Error! Couldn't find $exe_release"
  echo "Rebuild needed?"
  proj_set_buildconf 'release'
  proj_config && proj_build
fi

mkdir -pv $deploydir
#rm -rf $deploydir/*

# copy DLLs dependencies
copy_mingw_deps $deploydir && copy_app_deps $deploydir

pushd $deploydir
echo "Executing $windeploy"
$windeploy --no-translations --no-webkit2 --release \
  --qmldir $qmldir \
  --plugindir ./plugins $exename
popd

echo -ne "\n\nDone!\n"
