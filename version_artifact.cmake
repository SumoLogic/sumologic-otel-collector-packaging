##
# This file is a CMake script and should be run in CMake's script mode.
# E.g. cmake -P fetch_artifacts.cmake
#
# Its purpose is to fetch otelcol-sumo matching the host system's operating
# system & CPU architecture from a given GitHub Actions workflow. This
# otelcol-sumo binary is used to determine the version for packages and is not
# included in the generated packages.
##

# Require CMake >= 3.24.1
cmake_minimum_required(VERSION 3.24.1 FATAL_ERROR)

# Required environment variables
if(NOT DEFINED ENV{GH_TOKEN})
  message(FATAL_ERROR "GH_TOKEN environment variable must be set")
endif()

if(NOT DEFINED ENV{GH_WORKFLOW_ID})
  message(FATAL_ERROR "GH_WORKFLOW_ID environment variable must be set")
endif()

# Required and optional programs. Attempts to find required and optional
# programs used to build the packages.
find_program(GH_PROGRAM gh REQUIRED)

# Include the CMakeDetermineSystem module manually as it is not included when
# CMake runs in script mode. This is required for the host's CPU architecture
# to be detected.
set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_SOURCE_DIR}/build/cmake")
include(CMakeDetermineSystem)

# Set supported platforms for version detection
set(_supported_platforms "")
list(APPEND _supported_platforms "darwin_amd64")
list(APPEND _supported_platforms "darwin_arm64")
list(APPEND _supported_platforms "linux_amd64")
list(APPEND _supported_platforms "linux_arm64")
list(APPEND _supported_platforms "windows_amd64")

# Detect host system
string(TOLOWER "${CMAKE_HOST_SYSTEM_NAME}" _os)
string(TOLOWER "${CMAKE_HOST_SYSTEM_PROCESSOR}" _arch)

# Convert _arch to GOARCH equivalent name
if("${_arch}" STREQUAL "aarch64")
  set(_arch "arm64")
endif()

if("${_arch}" STREQUAL "x86_64")
  set(_arch "amd64")
endif()

set(_platform "${_os}_${_arch}")
message(STATUS "Detected platform: ${_platform}")

if(NOT "${_platform}" IN_LIST _supported_platforms)
  message(FATAL_ERROR "This script does not support this machine's platform: ${_platform}")
endif()

set(_bin_ext "")
if("${_os}" STREQUAL "windows")
  set(_bin_ext ".exe")
endif()

# Set directory variables
set(UTILS_DIR "${CMAKE_SOURCE_DIR}/utils")
set(_build_dir "${CMAKE_SOURCE_DIR}/build")
set(_version_detection_dir "${_build_dir}/version_detection")

# Include CMake files
include("${CMAKE_SOURCE_DIR}/utils.cmake")

# GitHub variables
set(_gh_org "SumoLogic")
set(_gh_repo "sumologic-otel-collector")
set(_gh_slug "${_gh_org}/${_gh_repo}")
set(_gh_workflow "$ENV{GH_WORKFLOW_ID}")

# Remote OTC artifact
set(_artifact_bin "otelcol-sumo-${_os}_${_arch}${_bin_ext}")
set(_artifact_path "${_version_detection_dir}/${_artifact_bin}")
set(_new_artifact_bin "otelcol-sumo${_bin_ext}")
set(_new_artifact_path "${_version_detection_dir}/${_new_artifact_bin}")

if(NOT EXISTS "${_new_artifact_path}")
  # Construct download command
  set(_cmd "${GH_PROGRAM}")
  set(_args_str "run download -R ${_gh_slug} ${_gh_workflow}")
  set(_args_str "${_args_str} -n ${_artifact_bin}")
  separate_arguments(_args NATIVE_COMMAND ${_args_str})

  # Create the version_detection directory
  make_directory("${_version_detection_dir}")

  message(STATUS "Setting working directory: ${_version_detection_dir}")
  message(STATUS "Running download command: ${_cmd} ${_args_str}")

  # Execute download command
  execute_process(COMMAND "${_cmd}" ${_args}
    WORKING_DIRECTORY ${_version_detection_dir}
    COMMAND_ERROR_IS_FATAL ANY)

  # Rename downloaded artifact to otelcol-sumo
  file(RENAME ${_artifact_path} ${_new_artifact_path})
endif()

# Detect version
detect_version("${_new_artifact_bin}" "${_version_detection_dir}")
