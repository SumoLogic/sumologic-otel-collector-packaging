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

# Fedora 42
function(fedora_42)
  set(_distro_name "Fedora 42")
  set(_distro_index_name "fedora/42")
  set(_supported_architectures
    "aarch64"
    "x86_64"
    "ppc64"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Fedora 41
function(fedora_41)
  set(_distro_name "Fedora 41")
  set(_distro_index_name "fedora/41")
  set(_supported_architectures
    "aarch64"
    "x86_64"
    "ppc64"
    "s390x"
  )
  check_architecture_support()
endfunction()
