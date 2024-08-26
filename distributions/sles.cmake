##
# SUSE Linux Enterprise Server releases
#
# Life Cycle: https://www.suse.com/lifecycle/#product-suse-linux-enterprise-server
# Release Notes: https://www.suse.com/releasenotes/index.html
##

# SUSE Linux Enterprise Server 15.6
#
# End of General Support: 6 months after SLES 15 SP7 release
# End of LTSS Support: 42 months after SLES 15 SP7 release
function(sles_15_6)
  set(_distro_name "SUSE Linux Enterprise Server 15.6")
  set(_distro_index_name "sles/15.6")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# SUSE Linux Enterprise Server 15.5
#
# End of General Support: December 31, 2024
# End of LTSS Support: December 31, 2027
function(sles_15_5)
  set(_distro_name "SUSE Linux Enterprise Server 15.5")
  set(_distro_index_name "sles/15.5")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# SUSE Linux Enterprise Server 15.4
#
# End of General Support: December 31, 2023
# End of LTSS Support: December 31, 2026
function(sles_15_4)
  set(_distro_name "SUSE Linux Enterprise Server 15.4")
  set(_distro_index_name "sles/15.4")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# SUSE Linux Enterprise Server 15.3
#
# End of General Support: December 31, 2022
# End of LTSS Support: December 31, 2025
function(sles_15_3)
  set(_distro_name "SUSE Linux Enterprise Server 15.3")
  set(_distro_index_name "sles/15.3")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# SUSE Linux Enterprise Server 15.2
#
# End of General Support: December 31, 2021
# End of LTSS Support: December 31, 2024
function(sles_15_2)
  set(_distro_name "SUSE Linux Enterprise Server 15.2")
  set(_distro_index_name "sles/15.2")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# SUSE Linux Enterprise Server 12.5
#
# End of General Support: October 31, 2024
# End of LTSS Support: October 31, 2027
function(sles_12_5)
  set(_distro_name "SUSE Linux Enterprise Server 12.5")
  set(_distro_index_name "sles/12.5")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()
