proj_set_target() {
  if [ -z $1 ]; then
    # check global env var
    if [ -z $curr_proj_target ]; then
      target="$host_plat (default)"
    else
      target=$curr_proj_target
    fi
  else
    target=$1
  fi
  case $target in
    Msys*64)
      prefix='x86_64-w64-mingw32'
      ;;
    *Linux*)
      # TODO always assuming host=target here
      prefix=''
      ;;
    *) return 1
  esac
  target_plat=$target

  # configure tools names
  if [ ! -z $prefix ]; then
    cmake=${prefix}-cmake
    run=$prefix-wine
  fi
  unset target
}

pushdir() { pushd $1 > /dev/null; }
popdir() { popd $1 > /dev/null; }

proj_config() {
  pushdir $builddir
  $cmake $projdir
  # FIXME temp (report mingw-x86-64-qt5-base-dynamic
  # bug for this)
  perl -pi -e 's/Qt5::rcc//' $buildfile
  popdir
}

proj_build() {
  pushdir $builddir
  make -j4
  popdir
}

proj_run() {
  pushdir $builddir
  $run $exe $@
  popdir
}

host_plat="$(uname)-$(uname -m)"
proj_set_target $1 || {
  echo "Unrecognized Platform: '$1'"
  return 1
}

script=$BASH_SOURCE
projdir_rel=$(dirname "$script")
projdir=$(pwd -L $projdir_rel)
builddir="$projdir/build-mingw"
buildfile="${builddir}/CMakeFiles/hellomingw.dir/build.make"
exe=$builddir/hellomingw

test -d $builddir || mkdir -p $builddir

echo "####### Project dir: $projdir"
echo "####### Build dir: $builddir"
echo "####### Host platform: $host_plat"
echo "####### Target platform: $target_plat"

