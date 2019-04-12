#!/usr/bin/sh.exe
# Environment Variables set from outside:
#
# BUILDNAME  - A descriptive name of the triggered build.
# PLATFORM   - A string of value unix/windows
# GIT_BRANCH - The target branch name that is tested.
# BITS       - The target architecture to build for.
# MODEL      - The deployment model: continues, nightly, experimental
# WORKSPACE  - The workspace with the checkout-$ENV{GIT_BRANCH} and build-$ENV{GIT_BRANCH} directories
# HOSTBITS   - [optional] The bits of the host platform: defaults to 64.
# THREADS    - [optional] The number of processor to use for build: defaults to 4

# Windows specific variables
# SEQAN_CTEST_GENERATOR          - One of Visual Studio 14 2015, ...
# SEQAN_CTEST_GENERATOR_TOOLSET  - [optional] One of: none, clang, intel, defaults to none

export BUILDNAME="test_win_jenkins_build"
export PLATFORM="windows"
export GIT_BRANCH="develop"
export BITS=64
export MODEL="Experimental"
export WORKSPACE="/c/Users/rmaerker/workspace/jenkins_test/workspace"
export WIN_SEQAN_CONTRIB_VERSION="D20170601"
export WIN_CTEST_GENERATOR="Visual Studio 15 2017"
# export WIN_CTEST_GENERATOR_TOOLSET="none"

cwd="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $cwd
. "$cwd/win_contrib.sh"
cd $cwd

echo "$SEQAN_WIN_CONTRIB_DIRECTORY"