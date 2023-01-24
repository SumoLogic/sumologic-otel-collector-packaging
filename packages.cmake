# Global properties containing lists of packaging targets which are used to
# create targets to build groups of packages at a time
set_property(GLOBAL PROPERTY all_package_targets)
set_property(GLOBAL PROPERTY all_linux_package_targets)
set_property(GLOBAL PROPERTY all_deb_package_targets)
set_property(GLOBAL PROPERTY all_rpm_package_targets)

# Creates targets for all packages targets
function(create_packages_targets)
  create_packages_target()
  create_linux_packages_target()
  create_deb_packages_target()
  create_rpm_packages_target()
endfunction()

# Creates a target for building all packages
function(create_packages_target)
  get_property(target_dependencies GLOBAL PROPERTY all_package_targets)
  add_custom_target("packages" DEPENDS ${target_dependencies})
endfunction()

# Creates a target for building all linux packages (e.g. deb & rpm)
function(create_linux_packages_target)
  get_property(target_dependencies GLOBAL PROPERTY all_linux_package_targets)
  add_custom_target("linux-packages" DEPENDS ${target_dependencies})
endfunction()

# Creates a target for building all deb packages
function(create_deb_packages_target)
  get_property(target_dependencies GLOBAL PROPERTY all_deb_package_targets)
  add_custom_target("deb-packages" DEPENDS ${target_dependencies})
endfunction()

# Creates a target for building all rpm packages
function(create_rpm_packages_target)
  get_property(target_dependencies GLOBAL PROPERTY all_rpm_package_targets)
  add_custom_target("rpm-packages" DEPENDS ${target_dependencies})
endfunction()

# Create a package target for a given package name and path to CPackConfig
function(create_package_target name cfg)
  add_custom_target(${name}
    COMMAND ${CMAKE_CPACK_COMMAND} --config ${cfg}
    DEPENDS ${cfg}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    VERBATIM
  )
endfunction()

# Build CPackConfig, create a target for building the package and add the target
# to the list of all package targets
macro(build_cpack_config)
  require_variables(
    "target_name"
  )

  append_github_output()

  set(CPACK_OUTPUT_CONFIG_FILE "${CMAKE_BINARY_DIR}/${target_name}-CPackConfig.cmake")

  # Build CPackConfig and store it on disk at path in CPACK_OUTPUT_CONFIG_FILE
  include(CPack)

  # Create a Makefile target for building the package and running any target
  # dependencies
  create_package_target("${target_name}" ${CPACK_OUTPUT_CONFIG_FILE})

  # Add target dependencies to run before the package target if
  # target_dependencies is defined
  if(DEFINED target_dependencies)
    add_dependencies("${target_name}" ${target_dependencies})
  endif()

  # Append the package target to the list of all package targets
  append_global_property(all_package_targets "${target_name}")
endmacro()

# Appends an output to the file defined by the GITHUB_OUTPUT environment
# variable. The output name is the name of the target and the value is the
# filename of the package that will be built. This is how we can notify
# GitHub Actions of the package filename so that it can be uploaded as an
# artifact.
macro(append_github_output)
  # Append the target name & package filename to the GITHUB_OUTPUT environment
  # variable if it is defined
  if(DEFINED ENV{GITHUB_OUTPUT})
    message(STATUS
      "The GITHUB_OUTPUT environment variable was detected; setting output: ${target_name}"
    )

    # Return an error if the value of GITHUB_OUTPUT is not a file
    if(NOT EXISTS "$ENV{GITHUB_OUTPUT}")
      message(FATAL_ERROR
        "The GITHUB_OUTPUT environment variable does not contain a path to an existing file"
      )
    endif()

    require_variables(
      CPACK_PACKAGE_FILE_NAME
      PACKAGE_FILE_EXTENSION
      target_name
    )

    file(APPEND
      "$ENV{GITHUB_OUTPUT}"
      "${target_name}=${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_FILE_EXTENSION}\n"
    )
  endif()
endmacro()

# Build CPackConfig & targets for deb
macro(build_deb_cpack_config)
  build_cpack_config()
  append_global_property(all_linux_package_targets "${target_name}")
  append_global_property(all_deb_package_targets "${target_name}")
  reset_cpack_state()
endmacro()

# Build CPackConfig & targets for rpm
macro(build_rpm_cpack_config)
  build_cpack_config()
  append_global_property(all_linux_package_targets "${target_name}")
  append_global_property(all_rpm_package_targets "${target_name}")
  reset_cpack_state()
endmacro()
