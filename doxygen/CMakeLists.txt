# Minimum cmake version
cmake_minimum_required(VERSION 3.0.0)

# Name of project
project(seqan3_documentation NONE)

### Find seqan3
if (NOT SEQAN3_INCLUDE_DIR)
    message(STATUS "Searching for seqan3.")
    find_package(SeqAn3)

    foreach(_include_dir in LISTS ${SEQAN3_INCLUDE_DIRS})
        if (EXISTS "${_include_dir/seqan3/version.hpp}")
            set(SEQAN3_INCLUDE_DIR "${_include_dir}")
            break()
        endif ()
    endforeach ()
endif ()

if (NOT EXISTS "${SEQAN3_INCLUDE_DIR}/seqan3/version.hpp")
    message(FATAL_ERROR "Could not find SeqAn3. Not building documentation.")
endif ()

### Find doxygen and dependency to DOT tool
message(STATUS "Searching for doxygen.")
find_package(Doxygen REQUIRED)

if (NOT ${DOXYGEN_FOUND})
    message(FATAL_ERROR "Could not find doxygen. Not building documentation.")
endif ()

if (NOT ${DOXYGEN_DOT_FOUND})
    message(STATUS "Could not find dot tool. Disabling dot support.")
    set(SEQAN3_DOXYGEN_HAVE_DOT "NO")
else ()
    message(STATUS "Found dot tool. Enabling dot support.")
    set(SEQAN3_DOXYGEN_HAVE_DOT "YES")
endif ()

### Find python interpreter
find_package(PythonInterp REQUIRED)

### Enable testing
enable_testing()

### Configure doc/developer targets.
set(seqan3_doxyfile_in ${CMAKE_SOURCE_DIR}/seqan3_doxygen_cfg.in)

option(SEQAN3_USER_DOC "Create build target and test for user documentation." ON)
option(SEQAN3_DEV_DOC "Create build target and test for developer documentation." ON)

if (SEQAN3_USER_DOC)
    message (STATUS "Configuring user doc.")

    set(SEQAN3_DOXYGEN_OUTPUT_DIR "${PROJECT_BINARY_DIR}/user_doc")
    set(SEQAN3_DOXYGEN_INCLUDE_DIR "${SEQAN3_INCLUDE_DIR}")
    set(SEQAN3_DOXYGEN_EXCLUDE_SYMBOLS "detail") #/""
    set(SEQAN3_DOXYGEN_PREDEFINED_NDEBUG "-NDEBUG") #/""
    set(SEQAN3_DOXYGEN_ENABLED_SECTIONS "") #/"DEV"
    set(SEQAN3_DOXYGEN_EXTRACT_PRIVATE "NO") #/"YES":
    set(seqan3_doxyfile_user ${PROJECT_BINARY_DIR}/seqan3_doxygen_cfg_user)

    configure_file(${seqan3_doxyfile_in} ${seqan3_doxyfile_user})

    add_custom_target(doc_user
                      COMMAND ${DOXYGEN_EXECUTABLE} ${seqan3_doxyfile_user}
                      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                      COMMENT "Generating user API documentation with Doxygen"
                      VERBATIM)
                      message (STATUS "Add user doc test.")
    add_test(NAME test_user_doc
             COMMAND ${PYTHON_EXECUTABLE}
             ${CMAKE_SOURCE_DIR}/doc_test.py "-e" ${DOXYGEN_EXECUTABLE} "-i" ${seqan3_doxyfile_user})
endif (SEQAN3_USER_DOC)

if (SEQAN3_DEV_DOC)
    message(STATUS "Configuring devel doc.")

    set(SEQAN3_DOXYGEN_OUTPUT_DIR "${PROJECT_BINARY_DIR}/devel_doc")
    set(SEQAN3_DOXYGEN_INCLUDE_DIR "${SEQAN3_INCLUDE_DIR}")
    set(SEQAN3_DOXYGEN_EXCLUDE_SYMBOLS "")
    set(SEQAN3_DOXYGEN_PREDEFINED_NDEBUG "")
    set(SEQAN3_DOXYGEN_ENABLED_SECTIONS "DEV")
    set(SEQAN3_DOXYGEN_EXTRACT_PRIVATE "YES")
    set(seqan3_doxyfile_devel ${PROJECT_BINARY_DIR}/seqan3_doxygen_cfg_devel)

    configure_file(${seqan3_doxyfile_in} ${seqan3_doxyfile_devel})

    add_custom_target(doc_devel
                      COMMAND ${DOXYGEN_EXECUTABLE} ${seqan3_doxyfile_devel}
                      WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
                      COMMENT "Generating developer API documentation with Doxygen"
                      VERBATIM)
                      message (STATUS "Add devel doc test.")
    add_test(NAME test_devel_doc
             COMMAND ${PYTHON_EXECUTABLE}
             ${CMAKE_SOURCE_DIR}/doc_test.py "-e" ${DOXYGEN_EXECUTABLE} "-i" ${seqan3_doxyfile_devel})
endif ()
