# Automated CTest Builds -- Workhorse File
#
# Do not define any new CTEST_* variables, prefix them with SEQAN!
#
# Variable ${CTEST_MODEL} comes from command line, this saves 1/2
# of CMake files.

CMAKE_MINIMUM_REQUIRED (VERSION 2.6)
cmake_policy (SET CMP0011 NEW)  # Suppress warning about PUSH/POP policy change.

# ---------------------------------------------------------------------------
# MANDATORY EXTERNAL VARIABLES
# ---------------------------------------------------------------------------

if (NOT DEFINED ENV{BUILDNAME})
    message (FATAL_ERROR "No BUILDNAME defined (can be arbitary STRING).")
endif (NOT DEFINED ENV{BUILDNAME})

# if (NOT DEFINED ENV{TESTROOT})
#     message (FATAL_ERROR "No TESTROOT defined (can be arbitrary existing DIR).")
# endif (NOT DEFINED ENV{TESTROOT})

if (NOT DEFINED ENV{GIT_BRANCH})
    message (FATAL_ERROR "No GIT_BRANCH defined (can be master or develop).")
endif (NOT DEFINED ENV{GIT_BRANCH})

if (NOT DEFINED ENV{BITS})
    message (FATAL_ERROR "No BITS defined (target bit size, should be 32 or 64)")
endif (NOT DEFINED ENV{BITS})

if (NOT DEFINED ENV{HOSTBITS})
    message (FATAL_ERROR "No HOSTBITS defined (host bit size, should be 32 or 64)")
endif (NOT DEFINED ENV{HOSTBITS})

if (NOT DEFINED ENV{MODEL})
    message (FATAL_ERROR "No MODEL defined (Nightly, Experimental or Continuous)")
endif (NOT DEFINED ENV{MODEL})

if (NOT $ENV{BITS} EQUAL $ENV{HOSTBITS})
    # setting CMAKE_CXX_FLAGS here doesnt work because they are overwritten later
    set(ENV{CFLAGS} "$ENV{CFLAGS} -m$ENV{BITS}")
    set(ENV{CXXFLAGS} "$ENV{CXXFLAGS} -m$ENV{BITS}")
endif (NOT $ENV{BITS} EQUAL $ENV{HOSTBITS})

# ---------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------

if (DEFINED ENV{THREADS})
    set (CTEST_BUILD_FLAGS "${CTEST_BUILD_FLAGS} -j $ENV{THREADS}")
endif (DEFINED ENV{THREADS})

# if ($ENV{GIT_BRANCH} STREQUAL "develop")
#     set(TRAK "BranchDevelop")
# else ($ENV{GIT_BRANCH} STREQUAL "develop")
#     set(TRAK "BranchMaster")
# endif ($ENV{GIT_BRANCH} STREQUAL "develop")

# if (DEFINED ENV{IS_NIGHTLY})
#     set(TRAK  "${TRAK}Nightly")
# else (DEFINED ENV{IS_NIGHTLY})
#     set(TRAK  "${TRAK}Manual")
# endif (DEFINED ENV{IS_NIGHTLY})

# ------------------------------------------------------------
# Set CTest variables describing the build.
# ------------------------------------------------------------

# determine full host name
find_program(HOSTNAME_CMD NAMES hostname)
EXECUTE_PROCESS(COMMAND ${HOSTNAME_CMD} -f OUTPUT_VARIABLE FULL_HOSTNAME OUTPUT_STRIP_TRAILING_WHITESPACE)

# This project name is used for the CDash submission.
SET (CTEST_PROJECT_NAME "SeqAn")
set (CTEST_CMAKE_GENERATOR "Unix Makefiles")
set (CTEST_BUILD_NAME "$ENV{BUILDNAME}")
set (CTEST_SITE "${FULL_HOSTNAME}")

set (CTEST_NIGHTLY_START_TIME "00:00:00 UTC")
set (CTEST_DROP_METHOD "http")
set (CTEST_DROP_SITE "cdash.seqan.de")
set (CTEST_DROP_LOCATION "/submit.php?project=SeqAn")
set (CTEST_DROP_SITE_CDASH TRUE)

set (CTEST_TIMEOUT 600)
if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
    set (CTEST_TIMEOUT 7200)
endif (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")

# Increase reported warning and error count.
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS   1000)
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 1000)

# ------------------------------------------------------------
# Set CTest variables for directories.
# ------------------------------------------------------------

# In theory one checkout for develop and master each would be enough
# but since multiple scripts might run in parallel they might conflict
# TODO(h4nn3s) move git clone and update into the sh script where locking
# can be used to prevent multiple checkout dirs
# WARNING then the changed files feature won't work, so maybe not.

# The Git checkout goes here.
set (CTEST_SOURCE_ROOT_DIRECTORY "$ENV{WORKSPACE}/checkout-$ENV{GIT_BRANCH}")
set (CTEST_SOURCE_DIRECTORY "${CTEST_SOURCE_ROOT_DIRECTORY}")

# Set build directory and directory to run tests in.
set (CTEST_BINARY_DIRECTORY "$ENV{WORKSPACE}/build-$ENV{GIT_BRANCH}")
set (CTEST_BINARY_TEST_DIRECTORY "${CTEST_BINARY_DIRECTORY}")

# ------------------------------------------------------------
# Set CTest variables for programs.
# ------------------------------------------------------------

# Give path to CMake.
set (CTEST_CMAKE_COMMAND cmake)
# find_program (CTEST_GIT_COMMAND NAMES git)
# if (NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")
#   set (CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone -b $ENV{GIT_BRANCH} https://github.com/rrahn/seqan.git ${CTEST_SOURCE_DIRECTORY}")
# endif ()
# set (CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")

# ------------------------------------------------------------
# Find memcheck and coverage programs.
# ------------------------------------------------------------

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

# Always write out the generator and some other settings.
file (WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
      CMAKE_GENERATOR:INTERNAL=${CTEST_CMAKE_GENERATOR}
      #MEMORYCHECK_COMMAND:FILEPATH=${CTEST_MEMORYCHECK_COMMAND}
      #MEMORYCHECK_COMMAND_OPTIONS:STRING=--supressions=${CTEST_SOURCE_ROOT_DIRECTORY}/util/valgrind/seqan.supp
      #COVERAGE_COMMAND:FILEPATH=${CTEST_COVERAGE_COMMAND}
      MODEL:STRING=$ENV{MODEL}
      CTEST_TEST_TIMEOUT:STRING=${CTEST_TEST_TIMEOUT}
      SEQAN_ENABLE_CUDA:BOOL=OFF
      ")
# Give CMAKE_FIND_ROOT_PATH to cmake process.
if (DEFINED ENV{SEQAN_CMAKE_FIND_ROOT_PATH})
  file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "CMAKE_FIND_ROOT_PATH:INTERNAL=$ENV{SEQAN_CMAKE_FIND_ROOT_PATH}
")
endif (DEFINED ENV{SEQAN_CMAKE_FIND_ROOT_PATH})

# When running memory checks then generate debug symbols, otherwise compile
# in Release mode.
if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
  file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
CMAKE_BUILD_TYPE:STRING=RelWithDebInfo")
else (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
  file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
CMAKE_BUILD_TYPE:STRING=Release")
endif (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")

# Allow disabling of library search in 64 bit dirs.
if (SEQAN_FIND_LIBRARY_USE_LIB64_PATHS_OFF)
    file (APPEND "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" "
SEQAN_FIND_LIBRARY_USE_LIB64_PATHS_OFF:BOOL=ON")
endif (SEQAN_FIND_LIBRARY_USE_LIB64_PATHS_OFF)

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
# endif (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")

CTEST_START ($ENV{MODEL} TRACK "$ENV{MODEL}-$ENV{GIT_BRANCH}")

# Update from repository, configure, build, test, submit.  These commands will
# get all necessary information from the CTEST_* variables set above.
message(" -- Update $ENV{MODEL} - ${CTEST_BUILD_NAME} --")
CTEST_CONFIGURE (RETURN_VALUE _CONFIG_RES)
CTEST_BUILD     (NUMBER_ERRORS _BUILD_ERRORS
                 NUMBER_WARNINGS _BUILD_WARNINGS)
CTEST_TEST      (PARALLEL_LEVEL $ENV{THREADS} RETURN_VALUE _TEST_RES)

# Run memory checks if configured to do so.
if (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")
  CTEST_MEMCHECK (BUILD "${CTEST_BINARY_TEST_DIRECTORY}")
endif (${CTEST_BUILD_NAME} MATCHES ".*memcheck.*")

# Run coverage checks if configured to do so.
if (${CTEST_BUILD_NAME} MATCHES ".*coverage.*")
  CTEST_COVERAGE(BUILD "${CTEST_BINARY_TEST_DIRECTORY}")
endif (${CTEST_BUILD_NAME} MATCHES ".*coverage.*")

#CTEST_SUBMIT    ()

# indicate errors
if (${_BUILD_ERRORS} GREATER 0 OR ${_BUILD_WARNINGS} GREATER 0 OR NOT ${_CONFIG_RES} EQUAL 0 OR NOT ${_TEST_RES} EQUAL 0)
  message(STATUS "build errors: ${_BUILD_ERRORS}; build warnings: ${_BUILD_WARNINGS}; config errors: ${_CONFIG_RES}; test failure: ${_TEST_RES}")
  message(FATAL_ERROR "Finished with errors")
  #file(APPEND "$ENV{WORKSPACE}/log/$ENV{BUILDNAME}.log" "build_failed")
endif ()
