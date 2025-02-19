#
# Copyright (C) 2013-2021 Draios Inc dba Sysdig.
#
# This file is part of sysdig .
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set(FALCOSECURITY_LIBS_CMAKE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules/falcosecurity-libs-repo")
set(FALCOSECURITY_LIBS_CMAKE_WORKING_DIR "${CMAKE_BINARY_DIR}/falcosecurity-libs-repo")

file(MAKE_DIRECTORY ${FALCOSECURITY_LIBS_CMAKE_WORKING_DIR})

if(FALCOSECURITY_LIBS_SOURCE_DIR)
  set(FALCOSECURITY_LIBS_VERSION "local")
  message(STATUS "Using local falcosecurity/libs in '${FALCOSECURITY_LIBS_SOURCE_DIR}'")
else()
  # The falcosecurity/libs git reference (branch name, commit hash, or tag) To update falcosecurity/libs version for the next release, change the
  # default below In case you want to test against another falcosecurity/libs version just pass the variable - ie., `cmake
  # -DFALCOSECURITY_LIBS_VERSION=dev ..`
  if(NOT FALCOSECURITY_LIBS_VERSION)
    set(FALCOSECURITY_LIBS_VERSION "f7029e2522cc4c81841817abeeeaa515ed944b6c")
    set(FALCOSECURITY_LIBS_CHECKSUM "SHA256=63e602c05db142465211e2d151d0ccd08fdb613fe85dd3603c8298bc0108823a")
  endif()

  # cd /path/to/build && cmake /path/to/source
  execute_process(COMMAND "${CMAKE_COMMAND}" -DFALCOSECURITY_LIBS_VERSION=${FALCOSECURITY_LIBS_VERSION} -DFALCOSECURITY_LIBS_CHECKSUM=${FALCOSECURITY_LIBS_CHECKSUM}
                          ${FALCOSECURITY_LIBS_CMAKE_SOURCE_DIR} WORKING_DIRECTORY ${FALCOSECURITY_LIBS_CMAKE_WORKING_DIR})

  # todo(leodido, fntlnz) > use the following one when CMake version will be >= 3.13

  # execute_process(COMMAND "${CMAKE_COMMAND}" -B ${FALCOSECURITY_LIBS_CMAKE_WORKING_DIR} WORKING_DIRECTORY
  # "${FALCOSECURITY_LIBS_CMAKE_SOURCE_DIR}")

  execute_process(COMMAND "${CMAKE_COMMAND}" --build . WORKING_DIRECTORY "${FALCOSECURITY_LIBS_CMAKE_WORKING_DIR}")
  set(FALCOSECURITY_LIBS_SOURCE_DIR "${FALCOSECURITY_LIBS_CMAKE_WORKING_DIR}/falcosecurity-libs-prefix/src/falcosecurity-libs")
endif()

set(PROBE_VERSION "${FALCOSECURITY_LIBS_VERSION}")

if(NOT LIBSCAP_DIR)
  set(LIBSCAP_DIR "${FALCOSECURITY_LIBS_SOURCE_DIR}")
endif()
set(LIBSINSP_DIR "${FALCOSECURITY_LIBS_SOURCE_DIR}")

# explicitly disable the tests of this dependency
set(CREATE_TEST_TARGETS OFF CACHE BOOL "")

set(WITH_CHISEL ON CACHE INTERNAL "" FORCE)

list(APPEND CMAKE_MODULE_PATH "${LIBSCAP_DIR}/cmake/modules")
list(APPEND CMAKE_MODULE_PATH "${LIBSINSP_DIR}/cmake/modules")

include(libscap)
include(libsinsp)
