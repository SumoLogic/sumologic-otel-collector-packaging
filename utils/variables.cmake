# Sets a variable in both the local & parent scope
macro(setg _name _value)
  set(${_name} ${_value})
  set(${_name} ${_value} PARENT_SCOPE)
endmacro()

# Sets a variable in the parent scope
macro(setp _name _value)
  set(${_name} ${_value} PARENT_SCOPE)
endmacro()

# Takes a list of variable names and ensures each variable is defined
function(require_variables varNames)
  foreach(varName ${varNames})
    if(NOT DEFINED ${varName})
      message(FATAL_ERROR "required variable is not set: ${varName}")
    endif()
  endforeach()
endfunction()
