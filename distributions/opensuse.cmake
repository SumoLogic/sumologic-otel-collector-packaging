##
# openSUSE releases
#
# Lifetime: https://en.opensuse.org/Lifetime
# Download: https://get.opensuse.org/leap/15.6/
##

# openSUSE Leap 15.6
#
# Expected to be maintained until at least end of December 2025.
function(opensuse_15_6)
  set(_distro_name "openSUSE Leap 15.6")
  set(_distro_index_name "opensuse/15.6")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()

# openSUSE Leap 15.5
#
# Expected to be maintained until end of December 2024.
function(opensuse_15_5)
  set(_distro_name "openSUSE Leap 15.5")
  set(_distro_index_name "opensuse/15.5")
  set(_supported_architectures
    "aarch64"
    "ppc64"
    "s390x"
    "x86_64"
  )
  check_architecture_support()
endfunction()
