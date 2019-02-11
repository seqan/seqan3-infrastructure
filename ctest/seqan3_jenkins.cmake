# Automated CTest Builds -- Workhorse File
# Author: Rene Rahn <rene.rahn[at]fu-berlin.de>
#
# Do not define any new CTEST_* variables, prefix them with SEQAN!
#
# Variable ${CTEST_MODEL} comes from command line, this saves 1/2
# of CMake files.
#
# Environment Variables set from outside:
#
# BUILDNAME      - A descriptive name of the triggered build.
# PLATFORM       - A string of value unix/windows
# MODEL          - The deployment model: continuous, nightly, experimental
# WORKSPACE      - The workspace with the checkout-$ENV{GIT_BRANCH} and build-$ENV{GIT_BRANCH} directories
# TEST_MODEL     - The test model to build and execute. One of 'unit', 'performance', 'mem', 'cov', 'header'.
# HOSTBITS       - [optional] The bits of the host platform: defaults to 64.
# THREADS        - [optional] The number of processor to use for build: defaults to 4
# DISABLE_CEREAL - [optional] Set to "ON" to switch off compilation with CEREAL. Default to "OFF" if not set.
# SITE_NAME      - [optional] The site name to display on cdash. Defaults to uname -n if not set.
#
# Windows specific variables
# WIN_CTEST_GENERATOR          - One of Visual Studio 14 2015, ...
# WIN_CTEST_GENERATOR_TOOLSET  - [optional] One of: none, clang, intel, defaults to none

CMAKE_MINIMUM_REQUIRED (VERSION 3.0)
cmake_policy (SET CMP0011 NEW)  # Suppress warning about PUSH/POP policy change.

# ---------------------------------------------------------------------------
# MANDATORY EXTERNAL VARIABLES
# ---------------------------------------------------------------------------

if (NOT DEFINED ENV{BUILDNAME})
    message (FATAL_ERROR "No BUILDNAME defined (can be arbitrary STRING).")
endif ()

if (NOT DEFINED ENV{PLATFORM})
    message (FATAL_ERROR "No Platform defined (should be unix or windows).")
endif ()

if (NOT DEFINED ENV{MODEL})
    set (ENV{MODEL} "Experimental")
endif ()

if (NOT DEFINED ENV{TEST_MODEL})
    message(FATAL_ERROR "No TEST_MODEL defined. Must be one of [unit, performance, mem, cov, header]")
endif ()

if (NOT DEFINED ENV{DISABLE_CEREAL})
    set (ENV{DISABLE_CEREAL} "OFF")
endif ()

# ---------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------

if (NOT DEFINED ENV{THREADS})
    set(ENV{THREADS} 4)
endif ()

set (CTEST_BUILD_FLAGS "${CTEST_BUILD_FLAGS} -j $ENV{THREADS}")

# ------------------------------------------------------------
# Set CTest variables describing the build.
# ------------------------------------------------------------

if (NOT DEFINED ENV{SITE_NAME})
    # determine full host name
    find_program(HOSTNAME_CMD NAMES uname)
    EXECUTE_PROCESS(COMMAND ${HOSTNAME_CMD} -n OUTPUT_VARIABLE FULL_HOSTNAME OUTPUT_STRIP_TRAILING_WHITESPACE)
else ()
    set (FULL_HOSTNAME "$ENV{SITE_NAME}")
endif ()

# This project name is used for the CDash submission.
SET (CTEST_PROJECT_NAME "SeqAn3")
set (CTEST_BUILD_NAME "$ENV{BUILDNAME}")
set (CTEST_SITE "${FULL_HOSTNAME}")

set (CTEST_NIGHTLY_START_TIME "02:00:00 UTC")
set (CTEST_DROP_METHOD "http")
set (CTEST_DROP_SITE "cdash.seqan.de")
set (CTEST_DROP_LOCATION "/submit.php?project=SeqAn3")
set (CTEST_DROP_SITE_CDASH TRUE)

#TODO Test these parameters
set (CTEST_TIMEOUT 600)
if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
    set (CTEST_TIMEOUT 7200)
endif ()

# Increase reported warning and error count.
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS   1000)
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 1000)
# Make sure the compiler generates errors and warnings in English.
set ($ENV{LC_MESSAGES} "en_EN")

# ------------------------------------------------------------
# Set CTest variables for directories.
# ------------------------------------------------------------

# Check different paths to execute tests.

if ("$ENV{TEST_MODEL}" STREQUAL "unit")
    set (_seqan3_src_dir "test/unit")
elseif ("$ENV{TEST_MODEL}" STREQUAL "performance")
    set (_seqan3_src_dir "test/performance")
elseif ("$ENV{TEST_MODEL}" STREQUAL "header")
    set (_seqan3_src_dir "test/header")
else ()
    message (FATAL_ERROR "Not supporting TEST_MODEL $ENV{TEST_MODEL} yet.")
endif ()

# The Git checkout goes here.
set (CTEST_SOURCE_ROOT_DIRECTORY "$ENV{WORKSPACE}/checkout/${_seqan3_src_dir}")
set (CTEST_SOURCE_DIRECTORY "${CTEST_SOURCE_ROOT_DIRECTORY}")

# Set build directory and directory to run tests in.
set (CTEST_BINARY_DIRECTORY "$ENV{WORKSPACE}/build")
set (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}")

# ------------------------------------------------------------
# Set CTest variables for programs.
# ------------------------------------------------------------

# Give path to CMake.
set (CTEST_CMAKE_COMMAND cmake)

# ------------------------------------------------------------
# Set CTest generator.
# ------------------------------------------------------------

set (CTEST_CMAKE_GENERATOR "Unix Makefiles")

# ------------------------------------------------------------
# Find memcheck and coverage programs.
# ------------------------------------------------------------

# TODO activate me!
# FIND_PROGRAM(CTEST_MEMORYCHECK_COMMAND NAMES valgrind)
# SET(CTEST_MEMORY_CHECK_COMMAND "/usr/bin/valgrind")
# SET(CTEST_MEMORYCHECK_COMMAND_OPTIONS "${CTEST_MEMORYCHECK_COMMAND_OPTIONS} --suppressions=${CTEST_SOURCE_ROOT_DIRECTORY}/util/valgrind/seqan.supp --suppressions=${CTEST_SOURCE_ROOT_DIRECTORY}/util/valgrind/python.supp --suppressions=/usr/lib/valgrind/python.supp")
# FIND_PROGRAM(CTEST_COVERAGE_COMMAND NAMES gcov)

# ------------------------------------------------------------
# Preparation of the binary directory.
# ------------------------------------------------------------

# Clear the binary directory to avoid problems.
CTEST_EMPTY_BINARY_DIRECTORY (${CTEST_BINARY_DIRECTORY})

# Write the initial cache to use for the binary tree.  Be careful to
# escape any quotes inside of this string if you use it.  This is the
# only way to communicate with the cmake process forked by ctest.
#
# Comments:
#
#   CMAKE_GENERATOR -- pass the generator
#      TODO(holtgrew): Neccesary?
#   CMAKE_BUILD_TYPE -- The build type.  We set this to Release since
#     the compiler tries its best to understand the code and unearths
#     some warning types only in this build type.
#   TODO Remove adding CMAKE_CXX_FLAGS after PR#117 is merged.
# Always write out the generator and some other settings.
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
      CMAKE_GENERATOR:INTERNAL=${CTEST_CMAKE_GENERATOR}
      CMAKE_BUILD_TYPE:STRING=Release
      #MEMORYCHECK_COMMAND:FILEPATH=${CTEST_MEMORYCHECK_COMMAND}
      #MEMORYCHECK_COMMAND_OPTIONS:STRING=--supressions=${CTEST_SOURCE_ROOT_DIRECTORY}/util/valgrind/seqan.supp
      #COVERAGE_COMMAND:FILEPATH=${CTEST_COVERAGE_COMMAND}
      MODEL:STRING=$ENV{MODEL}
      CTEST_TEST_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
      #CMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS} -pthread
      SEQAN3_NO_CEREAL:BOOL=$ENV{DISABLE_CEREAL}
      ")

# if (($ENV{PLATFORM} MATCHES "win") AND (NOT SEQAN_CTEST_GENERATOR_TOOLSET MATCHES "none"))
#     file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
#           CMAKE_GENERATOR_TOOLSET:INTERNAL=${CTEST_CMAKE_GENERATOR_TOOLSET}
#           ")
# endif ()

# Give CMAKE_FIND_ROOT_PATH to cmake process.
if (DEFINED ENV{SEQAN_CMAKE_FIND_ROOT_PATH})
  file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "CMAKE_FIND_ROOT_PATH:INTERNAL=$ENV{SEQAN_CMAKE_FIND_ROOT_PATH}
")
endif ()

# When running memory checks then generate debug symbols, otherwise compile
# in Release mode.
# if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
#   file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
# CMAKE_BUILD_TYPE:STRING=RelWithDebInfo")
# else (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
#   file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
# CMAKE_BUILD_TYPE:STRING=Release")
# endif ()
#
# # Allow disabling of library search in 64 bit dirs.
# if (SEQAN_FIND_LIBRARY_USE_LIB64_PATHS_OFF)
#     file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
# SEQAN_FIND_LIBRARY_USE_LIB64_PATHS_OFF:BOOL=ON")
# endif ()

# ------------------------------------------------------------
# Suppress certain warnings.
# ------------------------------------------------------------

# Of course, the following list should be kept as short as possible and should
# be limited to very small lists of system/compiler pairs.  However, some
# warnings cannot be suppressed from the source.  Also, the warnings
# suppressed here should be specific to certain system/compiler versions.
#
# If you add anything then document what it does.

set (CTEST_CUSTOM_WARNING_EXCEPTION
    # Suppress warnings about slow 64 bit atomic intrinsics.
    "compatibility.h.*: note:.*pragma message: slow.*64")

# ------------------------------------------------------------
# Perform the actual tests.
# ------------------------------------------------------------

## -- Start
message(" -- Start dashboard $ENV{MODEL} - ${CTEST_BUILD_NAME} --")

# if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
#     append sth to TRAK?
# endif ()

CTEST_START ($ENV{MODEL})

# Update from repository, configure, build, test, submit.  These commands will
# get all necessary information from the CTEST_* variables set above.
message(" -- Update $ENV{MODEL} - ${CTEST_BUILD_NAME} --")
# CTEST_UPDATE    (RETURN_VALUE VAL)

CTEST_CONFIGURE (RETURN_VALUE _CONFIG_RES)

CTEST_BUILD     (CONFIGURATION Release
                 NUMBER_ERRORS _BUILD_ERRORS
                 NUMBER_WARNINGS _BUILD_WARNINGS)

CTEST_TEST      (PARALLEL_LEVEL $ENV{THREADS} RETURN_VALUE _TEST_RES)

# TODO activate me
# Run memory checks if configured to do so.
# if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
#   CTEST_MEMCHECK (BUILD "${CTEST_BINARY_TEST_DIRECTORY}")
# endif ()

# TODO activate me
# Run coverage checks if configured to do so.
# if (${CTEST_BUILD_NAME} MATCHES ".*coverage.*")
#   CTEST_COVERAGE(BUILD "${CTEST_BINARY_TEST_DIRECTORY}")
# endif ()

CTEST_SUBMIT ()

# indicate errors
if (${_BUILD_ERRORS} GREATER 0 OR ${_BUILD_WARNINGS} GREATER 0 OR NOT ${_CONFIG_RES} EQUAL 0 OR NOT ${_TEST_RES} EQUAL 0)
  message(STATUS "build errors: ${_BUILD_ERRORS}; build warnings: ${_BUILD_WARNINGS}; config errors: ${_CONFIG_RES}; test failure: ${_TEST_RES}")
  message(FATAL_ERROR "Finished with errors")
endif ()
