# A property to store each package publish target
set_property(GLOBAL PROPERTY _all_publish_targets)
function(append_to_publish_targets)
    get_property(tmp GLOBAL PROPERTY _all_publish_targets)
    list(APPEND tmp ${ARGV})
    set_property(GLOBAL PROPERTY _all_publish_targets "${tmp}")
endfunction()

# Build CPackConfig, create a target for building the package and add the target
# to the list of all package targets
macro(build_cpack_config)
  require_variables(
    "CPACK_PACKAGE_FILE_NAME"
    "PACKAGE_FILE_EXTENSION"
    "OTC_BINARY"
    "OTC_CONFIG_BINARY"
    "SOURCE_OTC_BINARY"
    "SOURCE_OTC_CONFIG_BINARY"
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
        "GH_OUTPUT_OTC_CONFIG_BIN"
      )

      file(MAKE_DIRECTORY "${GH_ARTIFACTS_DIR}")
      file(CHMOD_RECURSE "${GH_ARTIFACTS_DIR}"
        DIRECTORY_PERMISSIONS
          OWNER_WRITE OWNER_READ OWNER_EXECUTE
          GROUP_WRITE GROUP_READ GROUP_EXECUTE
          WORLD_WRITE WORLD_READ WORLD_EXECUTE
      )
      set_github_output("otc-bin" "${GH_OUTPUT_OTC_BIN}")
      set_github_output("otc-config-bin" "${GH_OUTPUT_OTC_CONFIG_BIN}")
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

    # Create a target, if the target does not yet exist, for copying the
    # otelcol-config binary from the gh-actions directory to the artifacts
    # directory
    if(TARGET "${SOURCE_OTC_CONFIG_BINARY}")
      message(STATUS "Target already exists: ${SOURCE_OTC_CONFIG_BINARY}")
    else()
      message(STATUS "Creating target: ${SOURCE_OTC_CONFIG_BINARY}")
      file(MAKE_DIRECTORY "${SOURCE_OTC_CONFIG_BINARY_DIR}")
      add_custom_target("${SOURCE_OTC_CONFIG_BINARY}"
        ALL
        COMMAND ${CMAKE_COMMAND} -E copy ${GH_ARTIFACT_OTC_CONFIG_BINARY_PATH} ${SOURCE_OTC_CONFIG_BINARY_PATH}
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

    # Create a target for downloading the otelcol-config binary from GitHub
    # Releases if the target does not exist yet
    if(TARGET "${SOURCE_OTC_CONFIG_BINARY}")
      message(STATUS "Target already exists: ${SOURCE_OTC_CONFIG_BINARY}")
    else()
      message(STATUS "Creating target: ${SOURCE_OTC_CONFIG_BINARY}")
      require_variables("OTC_GIT_TAG")
      create_otelcol_sumo_target(
        "${SOURCE_OTC_CONFIG_BINARY}"
        "${OTC_CONFIG_BINARY}"
        "${OTC_GIT_TAG}"
        "${SOURCE_OTC_CONFIG_BINARY_DIR}"
      )
    endif()
  endif()

  set(_package_file "${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_FILE_EXTENSION}")
  set(_package_output "${CMAKE_BINARY_DIR}/${_package_file}")

  # Print out all of the Linux distributions that the package will be uploaded
  # for in Packagecloud
  print_packagecloud_distros()

  # Build CPackConfig
  include(CPack)

  # Create components
  create_otc_components()

  # Add a target for each packagecloud distro the package should be published to
  set(_pc_user "sumologic")
  set(_pc_repo "ci-builds")
  foreach(_pc_distro ${packagecloud_distros})
    create_packagecloud_publish_target(${_pc_user} ${_pc_repo} ${_pc_distro} ${_package_output})
  endforeach()

  # Add a target for uploading the package to Amazon S3
  set(_s3_channel "ci-builds")
  set(_version "${OTC_VERSION}-${BUILD_NUMBER}")
  set(_s3_bucket "sumologic-osc-${_s3_channel}")
  set(_s3_path "${_version}/")
  create_s3_cp_target(${_s3_bucket} ${_s3_path} ${_package_output})

  # Add a publish-package target to publish the package built above
  get_property(_all_publish_targets GLOBAL PROPERTY _all_publish_targets)
  add_custom_target(publish-package
    DEPENDS ${_all_publish_targets})

  # Add a wait-for-packagecloud-indexing target to wait for Packagecloud to finish indexing
  create_wait_for_packagecloud_indexing_target(${_pc_user} ${_pc_repo} ${_package_output})
endmacro()

# Create a Packagecloud publish target for uploading a package to a specific
# repository for a specific distribution.
function(create_packagecloud_publish_target _pc_user _pc_repo _pc_distro _pkg_path)
    set(_pc_output "${_pkg_path}-${_pc_repo}/${_pc_distro}")
    separate_arguments(_packagecloud_push_cmd
      UNIX_COMMAND "packagecloud push --skip-exists ${_pc_user}/${_pc_repo}/${_pc_distro} ${_pkg_path}")
    add_custom_command(OUTPUT ${_pc_output}
        COMMAND ${_packagecloud_push_cmd}
        DEPENDS ${_pkg_path}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        VERBATIM)
    append_to_publish_targets(${_pc_output})
endfunction()

# Create a Packagecloud wait for indexing target that will block until
# Packagecloud has finished indexing packages with the given package name.
function(create_wait_for_packagecloud_indexing_target _pc_user _pc_repo _pkg_path)
  set(_pc_output "${_pkg_path}-${_pc_repo}-wait-for-indexing")
  cmake_path(GET _pkg_path FILENAME _pkg_name)
  set(_repo_id "${_pc_user}/${_pc_repo}")
  set(_base_cmd "packagecloud search")
  set(_query_arg "--query ${_pkg_name}")
  set(_wait_args "--wait-for-indexing --wait-seconds 30 --wait-max-retries 12")
  set(_cmd "${_base_cmd} ${_repo_id} ${_query_arg} ${_wait_args}")
  separate_arguments(_packagecloud_search_cmd UNIX_COMMAND "${_cmd}")

  message(STATUS "wait for indexing command: ${_cmd}")

  add_custom_command(OUTPUT ${_pc_output}
    COMMAND ${_packagecloud_search_cmd}
    DEPENDS ${_pkg_name}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    VERBATIM)

  add_custom_target(wait-for-packagecloud-indexing
    DEPENDS ${_pc_output})
endfunction()

# Create an Amazon S3 publish target for uploading a package to an S3 bucket.
function(create_s3_cp_target _s3_bucket _s3_path _pkg_path)
    set(_s3_output "${_pkg_path}-s3-${_s3_bucket}")
    separate_arguments(_s3_cp_cmd UNIX_COMMAND "aws s3 cp ${_pkg_path} s3://${_s3_bucket}/${_s3_path}")
    add_custom_command(OUTPUT ${_s3_output}
        COMMAND ${_s3_cp_cmd}
        DEPENDS ${_pkg_path}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        VERBATIM)
    append_to_publish_targets(${_s3_output})
endfunction()

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
