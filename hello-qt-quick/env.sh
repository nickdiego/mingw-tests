proj_print_current_conf() {
  echo "####### projdir: $projdir"
  echo "####### host_plat: $host_plat"
  echo "####### target_plat: $target_plat"
  echo "####### confscript: $cmake"
  echo "####### buildconf: $buildconf"
  echo "####### builddir: $builddir"
}

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
      cmake=${prefix}-cmake
      run=${prefix}-wine
      ;;
    *Linux*)
      # TODO always assuming host=target here
      cmake=cmake
      run=''
      ;;
    *)
      echo "Unrecognized Platform: '$1'"
      return 1
  esac
  target_plat=$target
  unset target
}

pushdir() { pushd $1 > /dev/null; }
popdir() { popd $1 > /dev/null; }

push_buildir() {
  test -d $builddir || mkdir -pv $builddir
  pushdir $builddir || exit 1
}

proj_config() {
  push_buildir
  $cmake $projdir $conf_flags
  # FIXME temp (report mingw-x86-64-qt5-base-dynamic
  # bug for this)
  buildfile="${builddir}/CMakeFiles/hellomingw.dir/build.make"
  perl -pi -e 's/Qt5::rcc//' $buildfile
  popdir
}

proj_build() {
  push_buildir
  make -j4
  popdir
}

proj_run() {
  push_buildir
  $run $exe $@
  popdir
}

proj_set_buildconf() {
  conf=$1
  case $conf in
    debug)
      conf_flags='-DCMAKE_BUILD_TYPE=Debug'
      builddir=$builddir_debug
      deploydir=$deploydir_debug
      exe=$exe_debug
      ;;
    relase)
      conf_flags='-DCMAKE_BUILD_TYPE=Release'
      builddir=$builddir_release
      deploydir=$deploydir_release
      exe=$exe_release
      ;;
    *)
      echo "Unrecognized buildconf: '$conf'"
      return 1
  esac
  buildconf=$conf
}

proj_build_dir() {
  echo "$projdir/.build/${target_plat}-$1"
}

proj_deploy_dir() {
  echo "$projdir/.deploy/${target_plat}-$1"
}

#### Let'go!

scriptdir=$(dirname $BASH_SOURCE)
projdir=$(readlink -f $scriptdir)

host_plat="$(uname)-$(uname -m)"
proj_set_target $1 || return 1

builddir_debug=$(proj_build_dir 'debug')
builddir_release=$(proj_build_dir 'release')
exename=hellomingw
exe_debug=$builddir_debug/$exename
exe_release=$builddir_release/$exename
# TODO get this from command line option
proj_set_buildconf 'debug'

deploydir_debug=$(proj_deploy_dir 'debug')
deploydir_release=$(proj_deploy_dir 'release')

proj_print_current_conf
