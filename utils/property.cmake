# Appends a given value to a global property with a given name
function(append_global_property name value)
  get_property(tmp GLOBAL PROPERTY ${name})
  list(APPEND tmp ${value})
  set_property(GLOBAL PROPERTY ${name} "${tmp}")
endfunction()
