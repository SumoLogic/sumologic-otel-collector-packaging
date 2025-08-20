##
# SUSE Linux Enterprise Server releases
#
# Life Cycle: https://www.suse.com/lifecycle/#product-suse-linux-enterprise-server
# Release Notes: https://www.suse.com/releasenotes/index.html
##

# SUSE Linux Enterprise Server 15.7
#
# End of General Support: July 31, 2031
# End of LTSS Support: July 31, 2034
function(sles_15_7)
  set(_distro_name "SUSE Linux Enterprise Server 15.7")
  set(_distro_index_name "sles/15.7")
  set(_supported_architectures
    "aarch64"
    "ppc64le"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# SUSE Linux Enterprise Server 15.6
#
# End of General Support: November 28, 2025
# End of LTSS Support: June 30, 2031
function(sles_15_6)
  set(_distro_name "SUSE Linux Enterprise Server 15.6")
  set(_distro_index_name "sles/15.6")
  set(_supported_architectures
    "aarch64"
    "ppc64le"
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
    "ppc64le"
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
    "ppc64le"
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
    "ppc64le"
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
    "ppc64le"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()
