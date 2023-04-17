function(get_target_names varName)
  # Get a list of all target files
  file(GLOB TARGET_FILES
    LIST_DIRECTORIES false
    RELATIVE "${CMAKE_SOURCE_DIR}/targets"
    "targets/*.cmake"
  )

  # Strip extension from each file and append name to a list of target names
  foreach(TARGET_FILE ${TARGET_FILES})
    get_filename_component(TARGET_NAME ${TARGET_FILE} NAME_WE)
    list(APPEND TARGET_NAMES ${TARGET_NAME})
  endforeach()

  # Set the value of varName to TARGET_NAMES
  set(${varName} ${TARGET_NAMES} PARENT_SCOPE)
endfunction()

function(print_available_targets)
  message(STATUS "Available targets:")
  foreach(TARGET_NAME ${TARGET_NAMES})
    message(STATUS "  * ${TARGET_NAME}")
  endforeach()
endfunction()
