cmake_minimum_required (VERSION 3.4)

# Flags to use for every build.
set (NIGHTLY_GLOBAL_CXX_FLAGS "-Wno-psabi -DSEQAN3_DISABLE_LEGACY_STD_DIAGNOSTIC") # Suppresses changed ABI since gcc5 warnings. https://stackoverflow.com/q/52020305
# Definitions to use for every build.
set (NIGHTLY_GLOBAL_DEFINITIONS "-DSEQAN3_VERBOSE_TESTS=OFF -DSEQAN3_BENCHMARK_MIN_TIME=0.01")

# Timeout.
set (CTEST_TEST_TIMEOUT "240")

# Error counts.
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS   1000)
set (CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 1000)

# Require a testsuite, e.g. unit, snippet, performance, macro_benchmark, header, documentation.
if (NOT DEFINED TESTSUITE)
    message (FATAL_ERROR "No TESTSUITE defined.")
endif ()

# Require a ctest model, e.g. NIGHTLY, EXPERIMENTAL, CONTINUOUS
if (NOT DEFINED MODEL)
    message (FATAL_ERROR "No MODEL defined.")
endif ()

# Require a build type, e.g. Release, Debug.
if (NOT DEFINED CMAKE_BUILD_TYPE AND NOT TESTSUITE STREQUAL "documentation")
    message (FATAL_ERROR "No CMAKE_BUILD_TYPE defined.")
endif ()

# Require a c++ compiler.
if (NOT DEFINED CMAKE_CXX_COMPILER AND NOT TESTSUITE STREQUAL "documentation")
    message (FATAL_ERROR "No CMAKE_CXX_COMPILER defined.")
endif ()

# Default working directory will be the directory containing this script.
if (NOT DEFINED WORKING_DIRECTORY)
    set (NIGHTLY_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
else ()
    set (NIGHTLY_WORKING_DIRECTORY "${WORKING_DIRECTORY}")
endif ()

# Default number of threads will be logical CPUs / 2.
if (NOT DEFINED THREADS)
    cmake_host_system_information (RESULT NIGHTLY_NCPU QUERY NUMBER_OF_LOGICAL_CORES)
    math (EXPR NIGHTLY_THREADS "(${NIGHTLY_NCPU} + 1)/ 2" OUTPUT_FORMAT DECIMAL)
else ()
    set (NIGHTLY_THREADS "${THREADS}")
endif ()

# Store build name in two parts. Prefix will be aditionally used for CDASH submission.
#set (NIGHTLY_BUILD_NAME_PREFIX "${CMAKE_HOST_SYSTEM_NAME}-${CMAKE_HOST_SYSTEM_PROCESSOR}")
set (NIGHTLY_BUILD_NAME_PREFIX "release-3.0.3")
# This will also be used to locally create directories.
set (NIGHTLY_BUILD_NAME "${TESTSUITE} ${CMAKE_BUILD_TYPE} ${CMAKE_CXX_COMPILER}")
string (STRIP "${NIGHTLY_BUILD_NAME}" NIGHTLY_BUILD_NAME)

# Configure CXX_FLAGS.
if (DEFINED CPP17)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -fconcepts")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} cpp17")
elseif (DEFINED CPP2A)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++2a")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} cpp2a")
elseif (DEFINED CPP20)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++20")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} cpp20")
endif ()

if (DEFINED USAN)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=undefined")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} usan")
elseif (DEFINED ASAN)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} asan")
endif ()

if (DEFINED PRE_CXX11_ABI)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_GLIBCXX_USE_CXX11_ABI=0")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} pre_cxx11_abi")
endif ()

if (DEFINED FEDORA)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -flto -ffat-lto-objects -fexceptions -g -grecord-gcc-switches -pipe -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -fstack-protector-strong -m64 -mtune=powerpc64le -fasynchronous-unwind-tables -fstack-clash-protection -fcf-protection=check")
    set (NIGHTLY_BUILD_NAME "${NIGHTLY_BUILD_NAME} fedora")
endif ()

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${NIGHTLY_GLOBAL_CXX_FLAGS}")

# Store the hostname (not FQDN).
cmake_host_system_information (RESULT NIGHTLY_HOSTNAME QUERY HOSTNAME)

# Find git.
find_program (CTEST_GIT_COMMAND NAMES git)
set (CTEST_UPDATE_COMMAND "${CTEST_GIT_COMMAND}")
set (CTEST_GIT_INIT_SUBMODULES TRUE)

# CTEST configuration.
set (CTEST_PROJECT_NAME "SeqAn3")
set (CTEST_LABELS_FOR_SUBPROJECTS "${TESTSUITE}")
set (CTEST_CMAKE_GENERATOR "Unix Makefiles")
set (CTEST_BUILD_NAME "${NIGHTLY_BUILD_NAME_PREFIX} ${NIGHTLY_BUILD_NAME}")
set (CTEST_SITE "${NIGHTLY_HOSTNAME}")
set (CTEST_NIGHTLY_START_TIME "00:00:00 CEST")
set (CTEST_SUBMIT_URL "https://cdash.seqan.de/submit.php?project=${CTEST_PROJECT_NAME}")

set (CTEST_SOURCE_DIRECTORY "${NIGHTLY_WORKING_DIRECTORY}/src")
set (NIGHTLY_SOURCE_DIRECTORY "${CTEST_SOURCE_DIRECTORY}/test/${TESTSUITE}")
set (CTEST_BINARY_DIRECTORY "${NIGHTLY_WORKING_DIRECTORY}/build/${NIGHTLY_BUILD_NAME}")
string(REPLACE " " "_" CTEST_BINARY_DIRECTORY "${CTEST_BINARY_DIRECTORY}")

# Checkout will only occur if CTEST_CHECKOUT_COMMAND is defined.
if (NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")
    set (CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone --recurse-submodules https://github.com/seqan/seqan3.git ${CTEST_SOURCE_DIRECTORY}")
endif (NOT EXISTS "${CTEST_SOURCE_DIRECTORY}")

# Start.
message(" -- Start dashboard ${NIGHTLY_BUILD_NAME} --")
CTEST_START (${MODEL})

# Git checkout.
message(" -- Update ${NIGHTLY_BUILD_NAME} --")
CTEST_UPDATE ()

# Run cmake.
message(" -- Configure ${NIGHTLY_BUILD_NAME} --")
set (CTEST_CONFIGURE_COMMAND "cmake --no-warn-unused-cli \"-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}\" \"-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}\" \"-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}\" ${NIGHTLY_GLOBAL_DEFINITIONS} ${NIGHTLY_SOURCE_DIRECTORY}")
CTEST_CONFIGURE ()

# Update configurations for documentation build.
# Build step is skipped for documentation.
if (TESTSUITE STREQUAL "documentation")
    execute_process (COMMAND doxygen -u Doxyfile WORKING_DIRECTORY "${CTEST_BINARY_DIRECTORY}/doc_usr" OUTPUT_QUIET ERROR_QUIET)
    execute_process (COMMAND doxygen -u Doxyfile WORKING_DIRECTORY "${CTEST_BINARY_DIRECTORY}/doc_dev" OUTPUT_QUIET ERROR_QUIET)
    execute_process (COMMAND make download-cppreference-doxygen-web-tag WORKING_DIRECTORY "${CTEST_BINARY_DIRECTORY}" OUTPUT_QUIET ERROR_QUIET)
else ()
    message(" -- Build ${NIGHTLY_BUILD_NAME} --")
    set (CTEST_BUILD_FLAGS "${CTEST_BUILD_FLAGS} -j ${NIGHTLY_THREADS} -k")
    CTEST_BUILD ()
endif ()

# Run ctest. snippets can only use 1 thread.
message(" -- Test ${NIGHTLY_BUILD_NAME} --")
if (TESTSUITE STREQUAL "snippet")
    CTEST_TEST ()
else ()
    CTEST_TEST (PARALLEL_LEVEL "${NIGHTLY_THREADS}")
endif ()

# Submit to CDash. Retry if failure.
message(" -- Submit ${NIGHTLY_BUILD_NAME} --")
CTEST_SUBMIT (RETRY_COUNT 10
              RETRY_DELAY 30)

# Delete built documentation.
if (TESTSUITE STREQUAL "documentation")
    file (REMOVE_RECURSE "${CTEST_BINARY_DIRECTORY}/doc_usr")
    file (REMOVE_RECURSE "${CTEST_BINARY_DIRECTORY}/doc_dev")
endif ()

message(" -- Done ${NIGHTLY_BUILD_NAME} --")
