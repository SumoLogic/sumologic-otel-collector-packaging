# Takes a list of variable names and ensures each variable is defined
function(require_variables varNames)
  foreach(varName ${varNames})
    if(NOT DEFINED ${varName})
      message(FATAL_ERROR "required variable is not set: ${varName}")
    endif()
  endforeach()
endfunction()
