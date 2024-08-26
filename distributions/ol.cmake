##
# Oracle Linux releases
#
# End of Life: https://endoflife.date/oracle-linux
# Architectures: https://en.wikipedia.org/wiki/Oracle_Linux#Release_history
##

# Oracle Linux 9
#
# End of Basic/Premier Support: June 30, 2032
# End of Extended Support: June 30, 2035
function(ol_9)
  set(_distro_name "Oracle Linux 9.0")
  set(_distro_index_name "ol/9")
  set(_supported_architectures
    "aarch64"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# Oracle Linux 8
#
# End of Basic/Premier Support: July 31, 2029
# End of Extended Support: July 31, 2032
function(ol_8)
  set(_distro_name "Oracle Linux 8.0")
  set(_distro_index_name "ol/8")
  set(_supported_architectures
    "aarch64"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# Oracle Linux 7
#
# End of Basic/Premier Support: December 31, 2024
# End of Extended Support: June 30, 2028
function(ol_7)
  set(_distro_name "Oracle Linux 7.0")
  set(_distro_index_name "ol/7")
  set(_supported_architectures
    "aarch64"
    "x86_64"
  )
  check_architecture_support()
endfunction()
