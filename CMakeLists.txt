# Require CMake >= 3.24.1
cmake_minimum_required(VERSION 3.24.1 FATAL_ERROR)

# Set version information
include("${CMAKE_SOURCE_DIR}/version.cmake")

# Include CMake modules
include(ExternalProject)

# Set directory variables
set(ASSETS_DIR "${CMAKE_SOURCE_DIR}/assets")
set(COMPONENTS_DIR "${CMAKE_SOURCE_DIR}/components")
set(EXTERNAL_PROJECTS_DIR "${CMAKE_SOURCE_DIR}/external_projects")
set(PACKAGES_DIR "${CMAKE_SOURCE_DIR}/packages")
set(SETTINGS_DIR "${CMAKE_SOURCE_DIR}/settings")
set(TEMPLATES_DIR "${CMAKE_SOURCE_DIR}/templates")
set(TEMPLATES_OUTPUT_DIR "${CMAKE_BINARY_DIR}/templates_output")
set(UTILS_DIR "${CMAKE_SOURCE_DIR}/utils")

# Include CMake files
include("${CMAKE_SOURCE_DIR}/utils.cmake")
include("${CMAKE_SOURCE_DIR}/components.cmake")
include("${CMAKE_SOURCE_DIR}/external_projects.cmake")
include("${CMAKE_SOURCE_DIR}/templates.cmake")
include("${CMAKE_SOURCE_DIR}/packages.cmake")
include("${CMAKE_SOURCE_DIR}/settings.cmake")

# Prevent In-Source builds
validate_build_dir()

# Set project name, version, & set language to none to prevent the requirement
# of a compiler
project(otelcol-sumo
  VERSION "${OTC_VERSION}"
  LANGUAGES NONE)

# Create targets for downloading otelcol-sumo binaries
create_otelcol_sumo_target("linux" "amd64" false)
create_otelcol_sumo_target("linux" "amd64" true)
create_otelcol_sumo_target("linux" "arm64" false)

# Create target for downloading all otelcol-sumo binaries
create_otelcol_sumos_target()

# Include package functions
include("${PACKAGES_DIR}/otc_linux_amd64_deb.cmake")
include("${PACKAGES_DIR}/otc_linux_amd64_rpm.cmake")

# Build deb package configs & targets
package_otc_linux_amd64_deb()

# Build rpm package configs & targets
package_otc_linux_amd64_rpm()

# Create targets for all packages & groups of packages
create_packages_targets()
