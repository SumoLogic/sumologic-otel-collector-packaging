# Determine the OTC version and OTC Sumo version from the output of a previously
# downloaded build of the otelcol-sumo binary.
set(_version_artifact_bin "otelcol-sumo")
set(_version_detection_dir "${CMAKE_BINARY_DIR}/version_detection")
detect_version("${_version_artifact_bin}" "${_version_detection_dir}")

set(OTC_VERSION "${_otc_version}")
set(OTC_SUMO_VERSION "${_sumo_version}")

# OTC_BUILD_NUMBER represents the PACKAGE_RELEASE version used for incremental
# changes to the packaging code. This should contain a unique, unsigned integer
# that increments with each build to allow upgrades from one package version to
# another.
# A CI job number will typically be used for this value as it will naturally
# increase with each new package build.
# E.g. the X in A.B.C-X or A.B.C.X
if(DEFINED ENV{OTC_BUILD_NUMBER} AND NOT "$ENV{OTC_BUILD_NUMBER}" STREQUAL "")
  set(BUILD_NUMBER "$ENV{OTC_BUILD_NUMBER}")
else()
  set(BUILD_NUMBER "${OTC_SUMO_VERSION}")
endif()

if(NOT "${BUILD_NUMBER}" MATCHES "^[0-9]+$")
    message(FATAL_ERROR
      "OTC_BUILD_NUMBER contains an invalid version: ${BUILD_NUMBER}\n"
      "Must be an unsigned integer"
    )
endif()

message(STATUS "OTC Build Number is set to: ${BUILD_NUMBER}")
