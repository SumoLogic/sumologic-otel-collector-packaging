##
# Fedora releases
#
# Life Cycle: https://docs.fedoraproject.org/en-US/releases/lifecycle/
# Architectures:
#   * https://alt.fedoraproject.org/alt/
#   * https://fedoraproject.org/wiki/Architectures
#
# Fedora only supports the last two releases.
##

# Fedora 40
function(fedora_40)
  set(_distro_name "Fedora 40")
  set(_distro_index_name "fedora/40")
  set(_supported_architectures
    "aarch64"
    "x86_64"
    "ppc64"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Fedora 39
function(fedora_39)
  set(_distro_name "Fedora 39")
  set(_distro_index_name "fedora/39")
  set(_supported_architectures
    "aarch64"
    "x86_64"
    "ppc64"
    "s390x"
  )
  check_architecture_support()
endfunction()
