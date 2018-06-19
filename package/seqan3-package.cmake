# ============================================================================
#                  SeqAn - The Library for Sequence Analysis
# ============================================================================
#
# Copyright (c) 2006-2018, Knut Reinert & Freie Universitaet Berlin
# Copyright (c) 2016-2018, Knut Reinert & MPI Molekulare Genetik
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Knut Reinert or the FU Berlin nor the names of
#       its contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL KNUT REINERT OR THE FU BERLIN BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.
# ============================================================================

cmake_minimum_required (VERSION 3.2)

# ===========================================================================
# Helper functions.
# ===========================================================================

macro (today RESULT)
    if (WIN32)
        execute_process (COMMAND "date" "/T" OUTPUT_VARIABLE ${RESULT})
        string (REGEX REPLACE "(..)/(..)/(....).*" "\\3\\2\\1" ${RESULT} ${${RESULT}})
    elseif (UNIX)
        execute_process (COMMAND "date" "+%d/%m/%Y" OUTPUT_VARIABLE ${RESULT})
        string (REGEX REPLACE "(..)\/(..)\/(....).*" "\\3\\2\\1" ${RESULT} ${${RESULT}})
    else ()
        message (SEND_ERROR "Could not determine current date.")
        set (${RESULT} 00000000)
    endif ()
endmacro (today)

include (InstallRequiredSystemLibraries)

# ===========================================================================
# Identify root directory of seqan3 clone
# ===========================================================================

# We assume a git clone with submodules subfolder.
get_filename_component(_SEQAN3_CLONE_ROOT_DIR ${SEQAN3_BASEDIR} DIRECTORY)

# ===========================================================================
# Supported Archive Types
# ===========================================================================

# always set zip as archive.
set(CPACK_GENERATOR "ZIP")
set(CPACK_ZIP_COMPONENT_INSTALL ON)

if (WIN32) # Not yet supported.
    message (FATAL_ERROR "Packaging on Windows platforms is not yet supported.")
    return ()
elseif (APPLE)
    set(CPACK_GENERATOR "${CPACK_GENERATOR};TXZ;DragNDrop")
    set(CPACK_DragNDrop_COMPONENT_INSTALL ON)
    set(CPACK_TXZ_COMPONENT_INSTALL ON)
else () # Linux
    set(CPACK_GENERATOR "${CPACK_GENERATOR};TXZ")
    # set(CPACK_RPM_COMPONENT_INSTALL ON)
    # set(CPACK_DEB_COMPONENT_INSTALL ON)
    set(CPACK_TXZ_COMPONENT_INSTALL ON)
endif ()

# ===========================================================================
# SeqAn Package Description
# ===========================================================================

set (CPACK_PACKAGE_NAME "seqan3")

set (CPACK_PACKAGE_DESCRIPTION_SUMMARY "SeqAn - The C++ library for sequence analysis.")
set (CPACK_DEBIAN_PACKAGE_MAINTAINER "SeqAn Team <seqan-team@lists.fu-berlin.de>")
set (CPACK_PACKAGE_VENDOR "SeqAn Team, FU Berlin")
set (CPACK_PACKAGE_DESCRIPTION_FILE "${_SEQAN3_CLONE_ROOT_DIR}/README.md")
set (CPACK_RESOURCE_FILE_LICENSE "${_SEQAN3_CLONE_ROOT_DIR}/LICENSE")

option (SEQAN3_NIGHTLY_STABLE "Set to ON if triggered by stable nightly build" OFF)

if (SEQAN3_NIGHTLY_STABLE)
    today (DATE)
    set (CPACK_PACKAGE_VERSION "${DATE}")
else ()
    set (SEQAN3_VERSION "${SEQAN3_VERSION_MAJOR}.${SEQAN3_VERSION_MINOR}.${SEQAN3_VERSION_PATCH}")
    set (CPACK_PACKAGE_VERSION "${SEQAN3_VERSION}")
endif ()

set (CPACK_PACKAGE_VERSION_MAJOR "${SEQAN3_VERSION_MAJOR}")
set (CPACK_PACKAGE_VERSION_MINOR "${SEQAN3_VERSION_MINOR}")
set (CPACK_PACKAGE_VERSION_PATCH "${SEQAN3_VERSION_PATCH}")
set (CPACK_PACKAGE_INSTALL_DIRECTORY "SeqAn ${CPACK_PACKAGE_VERSION}")

set (CPACK_PACKAGE_FILE_NAME "seqan3-library-${CPACK_PACKAGE_VERSION}")
message (STATUS "Set package file name: ${CPACK_PACKAGE_FILE_NAME}")

# ===========================================================================
# Platform Dependent Install Directories
# ===========================================================================

if (UNIX)
    include (GNUInstallDirs)
endif ()

# For seqan3
set (SEQAN3_INSTALL_DOC_DIR "${CMAKE_INSTALL_DATADIR}/doc/seqan3")
set (SEQAN3_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/seqan3")
set (SEQAN3_INSTALL_CMAKE_DIR "${CMAKE_INSTALL_DATADIR}/cmake/seqan3")

# For range-v3
set (RANGE_INSTALL_DOC_DIR "${CMAKE_INSTALL_DATADIR}/doc/range/v3")
set (RANGE_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/range/v3")
set (RANGE_META_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/range/meta")

# For sdsl
    set (SDSL_INSTALL_DOC_DIR "${CMAKE_INSTALL_DATADIR}/doc/sdsl-lite")
    set (SDSL_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/sdsl-lite")

# For cereal
set (CEREAL_INSTALL_DOC_DIR "${CMAKE_INSTALL_DATADIR}/doc/cereal")
set (CEREAL_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/cereal")

# For lemon
set (LEMON_INSTALL_DOC_DIR "${CMAKE_INSTALL_DATADIR}/doc/lemon")
set (LEMON_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/lemon")

# ===========================================================================
# TODOs
# ===========================================================================

# CPACK_PACKAGE_ICON
