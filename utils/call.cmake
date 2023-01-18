function(call _id)
    if (NOT COMMAND ${_id})
        message(FATAL_ERROR "Unsupported function/macro \"${_id}\"")
    else()
        set(_helper "${CMAKE_BINARY_DIR}/helpers/macro_helper_${_id}.cmake")
        if (NOT EXISTS "${_helper}")
            file(WRITE "${_helper}" "${_id}(\$\{ARGN\})\n")
        endif()
        include("${_helper}")
    endif()
endfunction()
