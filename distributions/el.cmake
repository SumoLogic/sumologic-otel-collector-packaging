##
# Enterprise Linux releases
#
# Life Cycle: https://access.redhat.com/support/policy/updates/errata
# Architectures: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/8/html/considerations_in_adopting_rhel_8/architectures_considerations-in-adopting-rhel-8
##

# Enterprise Linux 9
#
# End of Full Support: May 31, 2027
# End of Maintenance Support: May 31, 2032
# End of Extended Life Cycle Support: May 31, 2035
function(el_9)
  set(_distro_name "Enterprise Linux 9.0")
  set(_distro_index_name "el/9")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# Enterprise Linux 8
#
# End of Full Support: May 31, 2024
# End of Maintenance Support: May 31, 2029
# End of Extended Life Cycle Support: May 31, 2032
function(el_8)
  set(_distro_name "Enterprise Linux 8.0")
  set(_distro_index_name "el/8")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# Enterprise Linux 7
#
# End of Full Support: August 6, 2019
# End of Maintenance Support: June 30, 2024
# End of Extended Life Cycle Support: June 30, 2028
function(el_7)
  set(_distro_name "Enterprise Linux 7.0")
  set(_distro_index_name "el/7")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()
