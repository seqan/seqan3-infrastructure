#!/bin/sh

# Add flags to suppress missing OpenMP warning in nightly builds.
export CXXFLAGS="${CXXFLAGS} -DSEQAN_IGNORE_MISSING_OPENMP=1"

# Make the software in /group/ag_abi/software/bin visible.
export PATH=/group/ag_abi/software/bin:${PATH}

if [ $BITS -eq 32 ]; then
    # For 32 bit builds, we need 32 bit versions of bzlib and zlib.
    export SEQAN_CMAKE_FIND_ROOT_PATH="/lib32;/usr/lib32"

    # Path to LEMON library.
    export LEMON_ROOT_DIR=/group/ag_abi/software/i686/lemon-1.2.3
else
    # Path to LEMON library.
    export LEMON_ROOT_DIR=/group/ag_abi/software/x86_64/lemon-1.2.3
fi

export COMPILERS=${COMPILERS-"g++-4.7 g++-4.8 g++-4.9 clang++-3.3 clang++-3.4 clang++-3.5"}
