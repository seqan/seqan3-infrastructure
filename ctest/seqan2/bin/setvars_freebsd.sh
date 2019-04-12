#!/bin/sh

# find the newest stl (this will make compiling with clang++ not be "really default"
# export LDFLAGS="${LDFLAGS} -Wl,-rpath=/usr/local/lib/gcc5"

# Add flags to suppress missing OpenMP warning in nightly builds.
export CXXFLAGS="${CXXFLAGS} -DSEQAN_IGNORE_MISSING_OPENMP=1"

## set of default compilers if not overwritten on CL
export COMPILERS=${COMPILERS-"clang++ g++5"}

