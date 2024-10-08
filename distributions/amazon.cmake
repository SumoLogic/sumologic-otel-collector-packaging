##
# Amazon Linux releases
#
# End of Life: https://endoflife.date/amazon-linux
##

# Amazon Linux 2023
#
# End of Standard Support: March 15, 2025
# End of Security Support: March 15, 2028
function(amazon_2023)
  set(_distro_name "Amazon Linux 2023")
  set(_distro_index_name "amazon/2023")
  set(_supported_architectures
    "aarch64"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# Amazon Linux 2
#
# End of Standard Support: June 30, 2025
# End of Security Support: June 30, 2025
function(amazon_2)
  set(_distro_name "Amazon Linux 2")
  set(_distro_index_name "amazon/2")
  set(_supported_architectures
    "aarch64"
    "x86_64"
  )
  check_architecture_support()
endfunction()
