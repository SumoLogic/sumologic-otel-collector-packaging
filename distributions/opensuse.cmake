##
# openSUSE releases
#
# Lifetime: https://en.opensuse.org/Lifetime
# Download: https://get.opensuse.org/leap/15.6/
##

# openSUSE Leap 15.6
#
# End of Life: December 31, 2025
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
