##
# openSUSE releases
#
# Lifetime: https://en.opensuse.org/Lifetime
# Download: https://get.opensuse.org/leap/15.6/
##

# openSUSE Leap 16.0
#
# End of Life: October 31, 2027
function(opensuse_16_0)
  set(_distro_name "openSUSE Leap 16.0")
  set(_distro_index_name "opensuse/16.0")
  set(_supported_architectures
    "aarch64"
    "ppc64le"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()


# openSUSE Leap 15.6
#
# End of Life: April 30, 2026
function(opensuse_15_6)
  set(_distro_name "openSUSE Leap 15.6")
  set(_distro_index_name "opensuse/15.6")
  set(_supported_architectures
    "aarch64"
    "ppc64le"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()
