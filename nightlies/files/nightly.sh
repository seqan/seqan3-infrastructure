#!/usr/bin/env bash

exec 3>&1 4>&2
trap_script() {
    for log in "seqan3" "sharg" "compiler"; do
        gzip -k -f /scratch/local/seiler/nightly-builds/${log}_log.txt
        scp /scratch/local/seiler/nightly-builds/${log}_log.txt.gz lounge:/web/docs.seqan.de/htdocs/seqan/develop_cdash_log/${log}_log.txt.gz
    done
    exec 2>&4 1>&3
}
trap trap_script EXIT
exec 1>/dev/null 2>&1

set -x

mkdir -p /dev/shm/seiler/ccache
mkdir -p /dev/shm/seiler/tmp

export TZ=Europe/Berlin
export TMPDIR=/dev/shm/seiler/tmp
export CCACHE_CONFIGPATH=/home/seiler/.ccache/ccache.conf
export PATH=/scratch/local/seiler/nightly-builds/nightly_compiler/wrapper:/scratch/local/seiler/nightly-builds/nightly_doxygen/doxygen-git/bin:$PATH

cd /scratch/local/seiler/nightly-builds

build_gcc_trunk ()
{
    echo "### Building gcc$compiler-git"
    set -e
    for compiler in "-10" "-11" "-12" ""; do
        if [ "$compiler" = "" ]; then
            branch="8be65640e12371571a88100864abd78733a7f7eb" # master
        else
            branch="releases/gcc${compiler}"
        fi

        cd /scratch/local/seiler/nightly-builds/nightly_compiler/gcc
        git fetch -u
        git checkout --force $branch
        rm -fdr gmp* isl* mpc* mpfr*
        ./contrib/download_prerequisites

        cd /scratch/local/seiler/nightly-builds/nightly_compiler/gcc$compiler-git
        make -k -j 120
        make install

        cd /scratch/local/seiler/nightly-builds
    done
    set +e
}

build_doxygen_trunk ()
{
    echo "### Building doxygen-git"
    cd /scratch/local/seiler/nightly-builds/nightly_doxygen/doxygen
    git fetch
    git reset --hard origin/master

    cd /scratch/local/seiler/nightly-builds/nightly_doxygen/doxygen-git
    cmake .
    make -k -j 80

    cd /scratch/local/seiler/nightly-builds
}

run_ctest_seqan3 ()
{
    ctest --verbose -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER="${1}" -D CMAKE_BUILD_TYPE="${2}" "${@:3}" -S seqan3_nightly.cmake
}

run_ctest_sharg ()
{
    ctest --verbose -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER="${1}" -D CMAKE_BUILD_TYPE="${2}" "${@:3}" -S sharg_nightly.cmake
}

########################################################################################################################
############################################# Build trunk version of tools #############################################
########################################################################################################################
echo "### Building compilers"
exec 1>/scratch/local/seiler/nightly-builds/compiler_log.txt 2>&1
build_gcc_trunk
build_doxygen_trunk
echo "### Built compilers"
exec 1>>/scratch/local/seiler/nightly-builds/seqan3_log.txt 2>&1

cd /scratch/local/seiler/nightly-builds/seqan3

########################################################################################################################
#################################################### Execute matrix ####################################################
########################################################################################################################
for suite in "unit"; do
    run_ctest_seqan3 g++-10 Debug
    run_ctest_seqan3 g++-11 Debug -D ASAN=1
    run_ctest_seqan3 g++-11 Debug -D USAN=1

    run_ctest_seqan3 g++-10-git Debug
    run_ctest_seqan3 g++-11-git Debug
    run_ctest_seqan3 g++-12-git Debug
    run_ctest_seqan3 g++-git    Debug

    run_ctest_seqan3 g++-11 Release -D PRE_CXX11_ABI=1
    run_ctest_seqan3 g++-11 Debug   -D FEDORA=1

    run_ctest_seqan3 g++-11     Debug -D CXX23=1
    run_ctest_seqan3 g++-11-git Debug -D CXX23=1
    run_ctest_seqan3 g++-12-git Debug -D CXX23=1
    run_ctest_seqan3 g++-git    Debug -D CXX23=1
done

for suite in "snippet" "performance" "macro_benchmark"; do
    run_ctest_seqan3 g++-10 Release
    run_ctest_seqan3 g++-10 Debug
    run_ctest_seqan3 g++-11 Release
    run_ctest_seqan3 g++-11 Debug   -D ASAN=1
    run_ctest_seqan3 g++-11 Debug   -D USAN=1

    run_ctest_seqan3 g++-10-git Debug
    run_ctest_seqan3 g++-11-git Debug
    run_ctest_seqan3 g++-12-git Debug
    run_ctest_seqan3 g++-git    Debug

    run_ctest_seqan3 g++-11     Debug -D CXX23=1
    run_ctest_seqan3 g++-11-git Debug -D CXX23=1
    run_ctest_seqan3 g++-12-git Debug -D CXX23=1
    run_ctest_seqan3 g++-git    Debug -D CXX23=1
done

for suite in "header"; do
    run_ctest_seqan3 g++-10 Release
    run_ctest_seqan3 g++-10 Debug
    run_ctest_seqan3 g++-11 Debug

    run_ctest_seqan3 g++-10-git Debug
    run_ctest_seqan3 g++-11-git Debug
    run_ctest_seqan3 g++-12-git Debug
    run_ctest_seqan3 g++-git    Debug

    run_ctest_seqan3 g++-11     Debug -D CXX23=1
    run_ctest_seqan3 g++-11-git Debug -D CXX23=1
    run_ctest_seqan3 g++-12-git Debug -D CXX23=1
    run_ctest_seqan3 g++-git    Debug -D CXX23=1
done

ctest --verbose -D MODEL=Nightly -D TESTSUITE=documentation -S seqan3_nightly.cmake

exec 1>>/scratch/local/seiler/nightly-builds/sharg_log.txt 2>&1

cd /scratch/local/seiler/nightly-builds/sharg

########################################################################################################################
#################################################### Execute matrix ####################################################
########################################################################################################################
for suite in "unit"; do
    run_ctest_sharg g++-10 Debug
    run_ctest_sharg g++-11 Debug -D ASAN=1
    run_ctest_sharg g++-11 Debug -D USAN=1

    run_ctest_sharg g++-10-git Debug
    run_ctest_sharg g++-11-git Debug
    run_ctest_sharg g++-12-git Debug
    run_ctest_sharg g++-git    Debug

    run_ctest_sharg g++-11 Release -D PRE_CXX11_ABI=1
    run_ctest_sharg g++-11 Debug   -D FEDORA=1

    run_ctest_sharg g++-11     Debug -D CXX23=1
    run_ctest_sharg g++-11-git Debug -D CXX23=1
    run_ctest_sharg g++-12-git Debug -D CXX23=1
    run_ctest_sharg g++-git    Debug -D CXX23=1
done

for suite in "snippet"; do
    run_ctest_sharg g++-10 Release
    run_ctest_sharg g++-10 Debug
    run_ctest_sharg g++-11 Release
    run_ctest_sharg g++-11 Debug   -D ASAN=1
    run_ctest_sharg g++-11 Debug   -D USAN=1

    run_ctest_sharg g++-10-git Debug
    run_ctest_sharg g++-11-git Debug
    run_ctest_sharg g++-12-git Debug
    run_ctest_sharg g++-git    Debug

    run_ctest_sharg g++-11     Debug -D CXX23=1
    run_ctest_sharg g++-11-git Debug -D CXX23=1
    run_ctest_sharg g++-12-git Debug -D CXX23=1
    run_ctest_sharg g++-git    Debug -D CXX23=1
done

for suite in "header"; do
    run_ctest_sharg g++-10 Release
    run_ctest_sharg g++-10 Debug
    run_ctest_sharg g++-11 Debug

    run_ctest_sharg g++-10-git Debug
    run_ctest_sharg g++-11-git Debug
    run_ctest_sharg g++-12-git Debug
    run_ctest_sharg g++-git    Debug

    run_ctest_sharg g++-11     Debug -D CXX23=1
    run_ctest_sharg g++-11-git Debug -D CXX23=1
    run_ctest_sharg g++-12-git Debug -D CXX23=1
    run_ctest_sharg g++-git    Debug -D CXX23=1
done

ctest --verbose -D MODEL=Nightly -D TESTSUITE=documentation -S sharg_nightly.cmake

