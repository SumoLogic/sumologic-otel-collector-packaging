# OTC_VERSION represents the base version of otelcol-sumo. This value is used to
# fetch the otelcol-sumo binary from GitHub and as the version of the packages
# produced by this project.
# E.g. the A.B.C in A.B.C-sumo-X
if(NOT DEFINED ENV{OTC_VERSION})
  message(FATAL_ERROR "OTC_VERSION environment variable must be set")
endif()

set(OTC_VERSION "$ENV{OTC_VERSION}")

if(NOT ${OTC_VERSION} MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
    message(FATAL_ERROR
      "OTC_VERSION contains an invalid version: ${OTC_VERSION}\n"
      "Must be in the form X.Y.Z"
    )
endif()

message(STATUS "OTC Version is set to: ${OTC_VERSION}")

# OTC_SUMO_VERSION represents the "sumo" version of otelcol-sumo. It is
# primarily used for fetching the otelcol-sumo binary from GitHub but it will
# also be used for the PACKAGE_RELEASE version (e.g. the X in A.B.C-X) if
# OTC_BUILD_NUMBER is not specified.
# E.g. the X in A.B.C-sumo-X
if(NOT DEFINED ENV{OTC_SUMO_VERSION})
  message(FATAL_ERROR "OTC_SUMO_VERSION environment variable must be set")
endif()

set(OTC_SUMO_VERSION "$ENV{OTC_SUMO_VERSION}")

if(NOT ${OTC_SUMO_VERSION} MATCHES "^([0-9]+)$")
    message(FATAL_ERROR
      "OTC_SUMO_VERSION contains an invalid version: ${OTC_SUMO_VERSION}\n"
      "Must be an unsigned integer"
    )
endif()

message(STATUS "OTC Sumo Version is set to: ${OTC_SUMO_VERSION}")

# OTC_BUILD_NUMBER represents the PACKAGE_RELEASE version used for incremental
# changes to the packaging code. This should contain a unique, unsigned integer
# that increments with each build to allow upgrades from one package to another.
# A CI job number will typically be used for this value.
# E.g. the X in A.B.C-X or A.B.C.X
if(DEFINED ENV{OTC_BUILD_NUMBER})
  set(BUILD_NUMBER "$ENV{OTC_BUILD_NUMBER}")
else()
  set(BUILD_NUMBER "${OTC_SUMO_VERSION}")
endif()

if(NOT ${BUILD_NUMBER} MATCHES "^([0-9]+)$")
    message(FATAL_ERROR
      "OTC_BUILD_NUMBER contains an invalid version: ${BUILD_NUMBER}\n"
      "Must be an unsigned integer"
    )
endif()

message(STATUS "OTC Build Number is set to: ${BUILD_NUMBER}")
