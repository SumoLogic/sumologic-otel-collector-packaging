# Build CPackConfig, create a target for building the package and add the target
# to the list of all package targets
macro(build_cpack_config)
  require_variables(
    "CPACK_PACKAGE_FILE_NAME"
    "PACKAGE_FILE_EXTENSION"
    "OTC_BINARY"
    "SOURCE_OTC_BINARY"
  )

  # Set a GitHub output with a name matching ${target_name}-pkg and a value
  # equal to the filename of the package that will be built. This provides
  # GitHub Actions with the package filename so that it can be uploaded as a
  # workflow artifact.
  set(package_file_name "${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_FILE_EXTENSION}")
  set_github_output("package_name" "${package_file_name}")

  # Set a GitHub output with a name matching ${target_name}-otc-bin and a value
  # equal to the name of the otelcol-sumo binary artifact that we want GitHub
  # Actions to fetch from the sumologic-otel-collector's GitHub Workflow
  # artifacts. This is only used when the OTC_ARTIFACTS_SOURCE environment
  # variable is set to "github-artifacts" which disables fetching artifacts from
  # a GitHub Release.
  if(DEFINED ENV{OTC_ARTIFACTS_SOURCE})
    if($ENV{OTC_ARTIFACTS_SOURCE} STREQUAL "github-artifacts")
      require_variables(
        "GH_ARTIFACTS_DIR"
        "GH_OUTPUT_OTC_BIN"
      )

      file(MAKE_DIRECTORY "${GH_ARTIFACTS_DIR}")
      file(CHMOD_RECURSE "${GH_ARTIFACTS_DIR}"
        DIRECTORY_PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_WRITE GROUP_READ GROUP_EXECUTE
          WORLD_WRITE WORLD_READ WORLD_EXECUTE
      )
      set_github_output("otc-bin" "${GH_OUTPUT_OTC_BIN}")
    else()
      message(FATAL_ERROR
        "Unsupported value for OTC_ARTIFACTS_SOURCE environment variable: $ENV{OTC_ARTIFACTS_SOURCE}"
      )
    endif()

    # Create a target, if the target does not yet exist, for copying the
    # otelcol-sumo binary from the gh-actions directory to the artifacts
    # directory
    if(TARGET "${SOURCE_OTC_BINARY}")
      message(STATUS "Target already exists: ${SOURCE_OTC_BINARY}")
    else()
      message(STATUS "Creating target: ${SOURCE_OTC_BINARY}")
      file(MAKE_DIRECTORY "${SOURCE_OTC_BINARY_DIR}")
      add_custom_target("${SOURCE_OTC_BINARY}"
        ALL
        COMMAND ${CMAKE_COMMAND} -E copy ${GH_ARTIFACT_OTC_BINARY_PATH} ${SOURCE_OTC_BINARY_PATH}
        VERBATIM
      )
    endif()
  else()
    # Create a target for downloading the otelcol-sumo binary from GitHub
    # Releases if the target does not exist yet
    if(TARGET "${SOURCE_OTC_BINARY}")
      message(STATUS "Target already exists: ${SOURCE_OTC_BINARY}")
    else()
      message(STATUS "Creating target: ${SOURCE_OTC_BINARY}")
      require_variables("OTC_GIT_TAG")
      create_otelcol_sumo_target(
        "${SOURCE_OTC_BINARY}"
        "${OTC_BINARY}"
        "${OTC_GIT_TAG}"
        "${SOURCE_OTC_BINARY_DIR}"
      )
    endif()
  endif()

  # Build CPackConfig
  include(CPack)
endmacro()

# Sets a GitHub output parameter by appending a statement to the file defined by
# the GITHUB_OUTPUT environment variable. It enables the passing of data from
# this CMake project to GitHub Actions.
function(set_github_output outputName outputValue)
  if(NOT DEFINED ENV{GITHUB_OUTPUT})
    message(STATUS
      "GITHUB_OUTPUT environment variable not detected. Skipping output: ${outputName}"
    )
    return()
  endif()

  # Return an error if the value of GITHUB_OUTPUT is not a file
  if(NOT EXISTS "$ENV{GITHUB_OUTPUT}")
    message(FATAL_ERROR
      "The GITHUB_OUTPUT environment variable does not contain a path to an existing file"
    )
  endif()

  file(APPEND "$ENV{GITHUB_OUTPUT}" "${outputName}=${outputValue}\n")
endfunction()

# Build CPackConfig & targets for deb
macro(build_deb_cpack_config)
  build_cpack_config()
  reset_cpack_state()
endmacro()

# Build CPackConfig & targets for productbuild
macro(build_productbuild_cpack_config)
  require_variables(
    "supported_archs"
  )

  # required for our CPack.distribution.dist.in template
  set(CPACK_PRODUCTBUILD_HOST_ARCHITECTURES "${supported_archs}")

  build_cpack_config()
  reset_cpack_state()
endmacro()

# Build CPackConfig & targets for rpm
macro(build_rpm_cpack_config)
  build_cpack_config()
  reset_cpack_state()
endmacro()
