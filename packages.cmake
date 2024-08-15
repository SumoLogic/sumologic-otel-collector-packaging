# Build CPackConfig, create a target for building the package and add the target
# to the list of all package targets
macro(build_cpack_config)
  require_variables(
    "CPACK_PACKAGE_FILE_NAME"
    "PACKAGE_FILE_EXTENSION"
  )

  # Set a GitHub output with a name matching ${target_name}-pkg and a value
  # equal to the filename of the package that will be built. This provides
  # GitHub Actions with the package filename so that it can be uploaded as a
  # workflow artifact.
  set(package_file_name "${CPACK_PACKAGE_FILE_NAME}.${PACKAGE_FILE_EXTENSION}")
  set_github_output("package_name" "${package_file_name}")

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

# Include package macros
include("${PACKAGES_DIR}/otc.cmake")
include("${PACKAGES_DIR}/otc_selinux.cmake")
