# Require CMake >= 3.24.1
cmake_minimum_required(VERSION 3.24.1 FATAL_ERROR)

# Required environment variables
if(NOT DEFINED ENV{GH_TOKEN})
  message(FATAL_ERROR "GH_TOKEN environment variable must be set")
endif()

if(NOT DEFINED ENV{GH_WORKFLOW_ID})
  message(FATAL_ERROR "GH_WORKFLOW_ID environment variable must be set")
endif()

set(GH_TOKEN "$ENV{GH_TOKEN}")
set(GH_WORKFLOW_ID "$ENV{GH_WORKFLOW_ID}")

# Required and optional programs. Attempts to find required and optional
# programs used to build the packages.
find_program(PACKAGECLOUD_PROGRAM packagecloud)
find_program(GH_PROGRAM gh REQUIRED)

# Include utils
set(UTILS_DIR "${CMAKE_SOURCE_DIR}/utils")
include("${CMAKE_SOURCE_DIR}/utils.cmake")

# Set version information
include("${CMAKE_SOURCE_DIR}/version.cmake")

# Include CMake modules
include(ExternalProject)
include(CPackComponent)

# Set directory variables
set(ASSETS_DIR "${CMAKE_SOURCE_DIR}/assets")
set(COMPONENTS_DIR "${CMAKE_SOURCE_DIR}/components")
set(DISTRIBUTIONS_DIR "${CMAKE_SOURCE_DIR}/distributions")
set(SETTINGS_DIR "${CMAKE_SOURCE_DIR}/settings")
set(TARGETS_DIR "${CMAKE_SOURCE_DIR}/targets")
set(TEMPLATES_DIR "${CMAKE_SOURCE_DIR}/templates")
set(TEMPLATES_OUTPUT_DIR "${CMAKE_BINARY_DIR}/templates_output")

# Include CMake files
include("${CMAKE_SOURCE_DIR}/components.cmake")
include("${CMAKE_SOURCE_DIR}/templates.cmake")
include("${CMAKE_SOURCE_DIR}/packages.cmake")
include("${CMAKE_SOURCE_DIR}/distributions.cmake")
include("${CMAKE_SOURCE_DIR}/settings.cmake")

# Add module paths
list(APPEND CMAKE_MODULE_PATH "${ASSETS_DIR}/productbuild")

# Prevent In-Source builds
validate_build_dir()

# Set project name, version, & set language to none to prevent the requirement
# of a compiler
project(otelcol-sumo
  VERSION "${OTC_VERSION}"
  LANGUAGES NONE)

set(TARGET "$ENV{TARGET}")

get_target_names(TARGET_NAMES)

if("${TARGET}" STREQUAL "")
  print_available_targets()
  message(FATAL_ERROR "TARGET environment variable must be set")
  return()
endif()

if(NOT "${TARGET}" IN_LIST TARGET_NAMES)
  print_available_targets()
  message(FATAL_ERROR "Target does not exist: ${TARGET}")
endif()

message(STATUS "Target is set to: ${TARGET}")

# Include target file
include("${TARGETS_DIR}/${TARGET}.cmake")
