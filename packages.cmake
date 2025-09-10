# A property to store each package publish target
set_property(GLOBAL PROPERTY _all_publish_targets)
function(append_to_publish_targets)
    get_property(tmp GLOBAL PROPERTY _all_publish_targets)
    list(APPEND tmp ${ARGV})
    set_property(GLOBAL PROPERTY _all_publish_targets "${tmp}")
endfunction()

function(download_github_artifact _slug _workflow_id _remote_filename _target)
  if(TARGET ${_target})
    message(STATUS "Target already exists: ${_remote_filename}")
  else()
    message(STATUS "Creating target: ${_remote_filename}")
    set(_cmd_str "${GH_PROGRAM} run download -R ${_gh_slug} ${_gh_workflow} -n ${_remote_filename}")
    separate_arguments(_cmd UNIX_COMMAND "${_cmd_str}")
    add_custom_command(
      OUTPUT ${_remote_filename}
      COMMAND ${_cmd}
      COMMENT "Downloading ${_remote_filename} from GitHub"
      VERBATIM
    )
    add_custom_target(${_target} ALL DEPENDS ${_remote_filename})
  endif()
endfunction()

# Build CPackConfig, create a target for building the package and add the target
# to the list of all package targets
macro(build_cpack_config)
  require_variables(
    "CPACK_PACKAGE_FILE_NAME"
    "GH_WORKFLOW_ID"
    "PACKAGE_FILE_EXTENSION"
    "OTC_BIN"
    "OTC_CONFIG_BIN"
    "REMOTE_OTC_BIN"
  )

  set(_gh_slug "SumoLogic/sumologic-otel-collector")
  set(_gh_workflow "${GH_WORKFLOW_ID}")

  download_github_artifact(${_gh_slug} ${_gh_workflow} ${REMOTE_OTC_BIN} ${OTC_BIN})
  download_github_artifact(${_gh_slug} ${_gh_workflow} ${REMOTE_OTC_CONFIG_BIN} ${OTC_CONFIG_BIN})

  # Set a GitHub output with a name matching ${target_name}-pkg and a value
  # equal to the filename of the package that will be built. This provides
  # GitHub Actions with the package filename so that it can be uploaded as a
  # workflow artifact.
  set(package_file_name "${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_FILE_EXTENSION}")
  set_github_output("package_name" "${package_file_name}")

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
  create_s3_cp_target_new("sumo-otel-builds-dev-c64ec98a" ${_s3_path} ${_package_output})

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

# Create an Amazon S3 publish target for uploading a package to an S3 bucket.
function(create_s3_cp_target_new _s3_bucket _s3_path _pkg_path)
    set(_s3_output "${_pkg_path}-s3-${_s3_bucket}")
    separate_arguments(_s3_cp_cmd UNIX_COMMAND "AWS_ACCESS_KEY_ID=$ENV{AWS_ACCESS_KEY_ID_NEW} AWS_SECRET_ACCESS_KEY=$ENV{AWS_SECRET_ACCESS_KEY_NEW} aws s3 cp ${_pkg_path} s3://${_s3_bucket}/${_s3_path}")
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
