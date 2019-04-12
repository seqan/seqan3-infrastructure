#!/bin/sh

# Add flags to suppress missing OpenMP warning in nightly builds.
export CXXFLAGS="${CXXFLAGS} -DSEQAN_IGNORE_MISSING_OPENMP=1"

# # Export the python path to point to the checkout.
# export PYTHONPATH=$ENV{HOME}/Documents/Development/Nightly/seqan-trunk/util/py_lib

# Make the software in /group/agabi/software/bin visible.
export PATH=/opt/local/bin:/opt/local/sbin:/usr/local/cuda/bin:/usr/usr/bin/:$PATH

## set of default compilers if not overwritten on CL
if [ "$GIT_BRANCH" = "develop" ]; then
	export COMPILERS=${COMPILERS-"clang++ g++-mp-4.9 g++-mp-5 g++-mp-6 clang++-mp-3.5 clang++-mp-3.6 clang++-mp-3.7"}
else
	export COMPILERS=${COMPILERS-"clang++ g++-mp-4.9 g++-mp-5 g++-mp-6 clang++-mp-3.5 clang++-mp-3.6 clang++-mp-3.7"}
fi

