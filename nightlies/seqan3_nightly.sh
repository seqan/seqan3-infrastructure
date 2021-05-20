#!/bin/sh
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/scratch/local/seiler/nightly-builds/log.txt 2>&1

set -ex

mkdir -p /dev/shm/seiler/ccache
mkdir -p /dev/shm/seiler/tmp

export TMPDIR=/dev/shm/seiler/tmp
export PATH=/scratch/local/seiler/nightly-builds/nightly_doxygen/doxygen-git/bin:$PATH

cd /scratch/local/seiler/nightly-builds

build_gcc_trunk ()
{
    for compiler in "-9" "-10" "-11" ""; do
        if [ "$compiler" = "" ]; then
            branch="master"
        else
            branch="releases/gcc${compiler}"
        fi

        cd /scratch/local/seiler/nightly-builds/nightly_compiler/gcc
        git fetch -u
        git checkout --force $branch

        cd /scratch/local/seiler/nightly-builds/nightly_compiler/gcc$compiler-git
        make -k -j 120
        make install

        cd /scratch/local/seiler/nightly-builds
    done
}

build_doxygen_trunk ()
{
    cd /scratch/local/seiler/nightly-builds/nightly_doxygen/doxygen
    git fetch
    git reset --hard origin/master

    cd /scratch/local/seiler/nightly-builds/nightly_doxygen/doxygen-git
    cmake .
    make -k -j 80

    cd /scratch/local/seiler/nightly-builds
}

run_with_trunk ()
{
    export OLD_PATH=$PATH
    export OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH

    export PATH=/scratch/local/seiler/nightly-builds/nightly_compiler/gcc$1-git/bin:$PATH
    export LD_LIBRARY_PATH=/scratch/local/seiler/nightly-builds/nightly_compiler/gcc$1-git/lib64/:$LD_LIBRARY_PATH

    if [ "$1" = "-9" ]; then
        ctest -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER=g++$1-git -D CMAKE_BUILD_TYPE=Debug -D CPP17=1 -S seqan3_nightly.cmake
        ctest -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER=g++$1-git -D CMAKE_BUILD_TYPE=Debug -D CPP2A=1 -S seqan3_nightly.cmake
    else
        ctest -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER=g++$1-git -D CMAKE_BUILD_TYPE=Debug -D CPP20=1 -S seqan3_nightly.cmake
    fi

    export PATH=$OLD_PATH
    export LD_LIBRARY_PATH=$OLD_LD_LIBRARY_PATH
}

########################################################################################################################
############################################# Build trunk version of tools #############################################
########################################################################################################################
build_gcc_trunk
build_doxygen_trunk

########################################################################################################################
#################################################### Execute matrix ####################################################
########################################################################################################################
for suite in "unit" "snippet" "performance" "macro_benchmark"; do
    ctest -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER=g++-9  -D CMAKE_BUILD_TYPE=Release -D CPP17=1           -S seqan3_nightly.cmake
    ctest -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER=g++-10 -D CMAKE_BUILD_TYPE=Debug   -D CPP20=1 -D ASAN=1 -S seqan3_nightly.cmake
    ctest -D MODEL=Nightly -D TESTSUITE=$suite -D CMAKE_CXX_COMPILER=g++-10 -D CMAKE_BUILD_TYPE=Debug   -D CPP20=1 -D USAN=1 -S seqan3_nightly.cmake

    run_with_trunk "-9"
    run_with_trunk "-10"
    run_with_trunk "-11"
    run_with_trunk ""
done

ctest -D MODEL=Nightly -D TESTSUITE=header -D CMAKE_CXX_COMPILER=g++-9  -D CMAKE_BUILD_TYPE=Release -D CPP17=1 -S seqan3_nightly.cmake
ctest -D MODEL=Nightly -D TESTSUITE=header -D CMAKE_CXX_COMPILER=g++-11 -D CMAKE_BUILD_TYPE=Release -D CPP20=1 -S seqan3_nightly.cmake
ctest -D MODEL=Nightly -D TESTSUITE=header -D CMAKE_CXX_COMPILER=g++-9  -D CMAKE_BUILD_TYPE=Debug   -D CPP17=1 -S seqan3_nightly.cmake
ctest -D MODEL=Nightly -D TESTSUITE=header -D CMAKE_CXX_COMPILER=g++-11 -D CMAKE_BUILD_TYPE=Debug   -D CPP20=1 -S seqan3_nightly.cmake

ctest -D MODEL=Nightly -D TESTSUITE=documentation -S seqan3_nightly.cmake
ctest -D MODEL=Nightly -D TESTSUITE=unit -D CMAKE_CXX_COMPILER=g++-9  -D CMAKE_BUILD_TYPE=Release -D CPP17=1 -D PRE_CXX11_ABI=1 -S seqan3_nightly.cmake
ctest -D MODEL=Nightly -D TESTSUITE=unit -D CMAKE_CXX_COMPILER=g++-11 -D CMAKE_BUILD_TYPE=Debug   -D CPP20=1 -D FEDORA=1        -S seqan3_nightly.cmake
