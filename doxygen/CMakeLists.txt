# Minimum cmake version
cmake_minimum_required(VERSION 3.0.0)

# Name of project
project(seqan3_documentation NONE)

### Find seqan3
if (NOT SEQAN3_INCLUDE_DIR)
    message (STATUS "Searching for seqan3.")
    find_package (SeqAn3 REQUIRED)

    foreach (_include_dir in LISTS ${SEQAN3_INCLUDE_DIRS})
        if (EXISTS "${_include_dir/seqan3/version.hpp}")
            set(SEQAN3_INCLUDE_DIR "${_include_dir}")
            break()
        endif ()
    endforeach ()
endif ()

if (NOT EXISTS "${SEQAN3_INCLUDE_DIR}/seqan3/version.hpp")
    message (FATAL_ERROR "Could not find SeqAn3. Not building documentation.")
endif ()

set (SEQAN3_DOXYGEN_INPUT_DIR "${CMAKE_SOURCE_DIR}")

include (seqan3-doxygen.cmake)

### Find python interpreter
find_package(PythonInterp REQUIRED)

### Enable testing
enable_testing()

if (SEQAN3_USER_DOC)
    message (STATUS "Add user doc test.")
    add_test(NAME test_user_doc
             COMMAND ${PYTHON_EXECUTABLE}
             ${CMAKE_SOURCE_DIR}/doc_test.py "-e" ${DOXYGEN_EXECUTABLE} "-i" ${seqan3_doxyfile_user})
endif ()

if (SEQAN3_DEV_DOC)
    message (STATUS "Add dev doc test.")
    add_test(NAME test_devel_doc
             COMMAND ${PYTHON_EXECUTABLE}
             ${CMAKE_SOURCE_DIR}/doc_test.py "-e" ${DOXYGEN_EXECUTABLE} "-i" ${seqan3_doxyfile_devel})
endif ()
