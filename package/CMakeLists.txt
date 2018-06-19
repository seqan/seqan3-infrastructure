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
# Control with -DCPACK_COMPONENTS_ALL=<component> which component should be
# installed.
# ============================================================================

cmake_minimum_required (VERSION 3.2)

project (seqan3_package CXX)

# ===========================================================================
# Find requirements.
# ===========================================================================

find_package (SeqAn3 REQUIRED
              HINTS ${CMAKE_CURRENT_LIST_DIR})

# Setup the packaging.
include (seqan3-package.cmake)

# ===========================================================================
# Install seqan3 header
# ===========================================================================

message (STATUS "_SEQAN3_CLONE_ROOT_DIR = ${_SEQAN3_CLONE_ROOT_DIR}")

# Install license and rename to copyright.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/LICENSE
         COMPONENT seqan3
         DESTINATION ${SEQAN3_INSTALL_DOC_DIR}
         RENAME copyright)

# Install README.md, CHANGELOG.md files.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/README.md
               ${_SEQAN3_CLONE_ROOT_DIR}/CHANGELOG.md
         COMPONENT seqan3
         DESTINATION ${SEQAN3_INSTALL_DOC_DIR}
         OPTIONAL)

# Install header files into directory.
install (DIRECTORY ${_SEQAN3_CLONE_ROOT_DIR}/include/seqan3/
         COMPONENT seqan3
         DESTINATION ${SEQAN3_INSTALL_INCLUDE_DIR}
         FILES_MATCHING PATTERN "*.hpp")

# ===========================================================================
# Install range-v3 header
# ===========================================================================

# Install license and rename to copyright.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/range-v3/LICENSE.txt
         DESTINATION ${RANGE_INSTALL_DOC_DIR}
         COMPONENT range-v3
         RENAME copyright)

# Install README.md, CHANGELOG.md files.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/range-v3/README.md
               ${_SEQAN3_CLONE_ROOT_DIR}/submodules/range-v3/CHANGELOG.md
         DESTINATION ${RANGE_INSTALL_DOC_DIR}
         COMPONENT range-v3
         OPTIONAL)

# Install header files into directory.
install (DIRECTORY ${_SEQAN3_CLONE_ROOT_DIR}/submodules/range-v3/include/meta/
         DESTINATION ${RANGE_META_INSTALL_INCLUDE_DIR}
         COMPONENT range-v3
         FILES_MATCHING PATTERN "*.hpp")

install (DIRECTORY ${_SEQAN3_CLONE_ROOT_DIR}/submodules/range-v3/include/range/v3/
         DESTINATION ${RANGE_INSTALL_INCLUDE_DIR}
         COMPONENT range-v3
         FILES_MATCHING PATTERN "*.hpp")

# ===========================================================================
# Install sdsl header
# ===========================================================================

# Install license and rename to copyright.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/sdsl-lite/LICENSE
         DESTINATION ${SDSL_INSTALL_DOC_DIR}
         COMPONENT sdsl-lite
         RENAME copyright)

# Install README.md, CHANGELOG.md files.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/sdsl-lite/README.md
               ${_SEQAN3_CLONE_ROOT_DIR}/submodules/sdsl-lite/CHANGELOG.md
         DESTINATION ${SDSL_INSTALL_DOC_DIR}
         COMPONENT sdsl-lite
         OPTIONAL)

# Install header files into directory.
install (DIRECTORY ${_SEQAN3_CLONE_ROOT_DIR}/submodules/sdsl-lite/include/sdsl/
         DESTINATION ${SDSL_INSTALL_INCLUDE_DIR}
         COMPONENT sdsl-lite
         FILES_MATCHING PATTERN "*.hpp")

# ===========================================================================
# Install cereal header
# ===========================================================================

# Install license and rename to copyright.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/cereal/LICENSE
         DESTINATION ${CEREAL_INSTALL_DOC_DIR}
         COMPONENT cereal
         RENAME copyright)

# Install README.md, CHANGELOG.md files.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/cereal/README.md
               ${_SEQAN3_CLONE_ROOT_DIR}/submodules/cereal/CHANGELOG.md
         DESTINATION ${CEREAL_INSTALL_DOC_DIR}
         COMPONENT cereal
         OPTIONAL)

# Install header files into directory.
install (DIRECTORY ${_SEQAN3_CLONE_ROOT_DIR}/submodules/cereal/include/cereal/
         DESTINATION ${CEREAL_INSTALL_INCLUDE_DIR}
         COMPONENT cereal
         FILES_MATCHING PATTERN "*.hpp")

# ===========================================================================
# Install lemon header
# ===========================================================================

# Install license and rename to copyright.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/lemon/LICENSE
         DESTINATION ${LEMON_INSTALL_DOC_DIR}
         COMPONENT lemon
         RENAME copyright)

# Install README.md, CHANGELOG.md files.
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/submodules/lemon/README
               ${_SEQAN3_CLONE_ROOT_DIR}/submodules/lemon/CHANGELOG.md
         DESTINATION ${LEMON_INSTALL_DOC_DIR}
         COMPONENT lemon
         OPTIONAL)

# Install header files into directory.
install (DIRECTORY ${_SEQAN3_CLONE_ROOT_DIR}/submodules/lemon/include/lemon/
         DESTINATION ${LEMON_INSTALL_INCLUDE_DIR}
         COMPONENT lemon
         FILES_MATCHING PATTERN "*.h")

# ===========================================================================
# Install cmake config file
# ===========================================================================

# Install seqan3-config.cmake
install (FILES ${_SEQAN3_CLONE_ROOT_DIR}/build_system/seqan3-config.cmake
         DESTINATION ${SEQAN3_INSTALL_CMAKE_DIR})

# ===========================================================================
# Build and install user documentation
# ===========================================================================

# prepare documentation build job
foreach (_include_dir ${SEQAN3_INCLUDE_DIRS})
    if (EXISTS "${_include_dir}/seqan3/version.hpp")
        set (SEQAN3_INCLUDE_DIR "${_include_dir}")
        message (STATUS "Found SeqAn3 include directory: ${SEQAN3_INCLUDE_DIR}")
        break ()
    endif ()
endforeach ()

set (SEQAN3_DOXYGEN_INPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../doxygen")

# add targets for building docu.
include (${CMAKE_CURRENT_SOURCE_DIR}/../doxygen/seqan3-doxygen.cmake)

# add install steps.
install(CODE "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build \"${CMAKE_CURRENT_BINARY_DIR}\" --target doc_user)")
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/user_doc/html/
        DESTINATION ${SEQAN3_INSTALL_DOC_DIR}/html)

# ===========================================================================
# Include cpack.
# ===========================================================================

include (CPack)
