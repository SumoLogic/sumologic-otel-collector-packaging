function(detect_version _artifact_bin _working_dir)
  # Construct version command
  set(_cmd_str "./${_artifact_bin} --version")
  separate_arguments(_cmd UNIX_COMMAND ${_cmd_str})

  message(STATUS "Setting working directory: ${_working_dir}")
  message(STATUS "Running version command: ${_cmd_str}")

  # Get output of otelcol-sumo --version
  execute_process(COMMAND ${_cmd}
    WORKING_DIRECTORY ${_working_dir}
    COMMAND_ERROR_IS_FATAL ANY
    OUTPUT_VARIABLE _version_output
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )

  message(STATUS "Version output: ${_version_output}")

  string(REGEX MATCH ".* ([0-9]+\.[0-9]+\.[0-9]+)\-sumo\-([0-9]+)\-.*" _ ${_version_output})

  if(NOT CMAKE_MATCH_COUNT EQUAL 2)
    message(FATAL_ERROR "Could not parse version information from version output")
  endif()

  set(_otc_version "${CMAKE_MATCH_1}")
  set(_sumo_version "${CMAKE_MATCH_2}")
  set(_otc_version "${_otc_version}" PARENT_SCOPE)
  set(_sumo_version "${_sumo_version}" PARENT_SCOPE)

  message(STATUS "Detected OTC version: ${_otc_version}")
  message(STATUS "Detected Sumo version: ${_sumo_version}")
endfunction()
