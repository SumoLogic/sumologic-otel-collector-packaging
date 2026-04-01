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

# Fedora 43
function(fedora_43)
  set(_distro_name "Fedora 43")
  set(_distro_index_name "fedora/43")
  set(_supported_architectures
    "aarch64"
    "x86_64"
    "mips64el"
    "mipsel"
    "ppc64le"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Fedora 42
function(fedora_42)
  set(_distro_name "Fedora 42")
  set(_distro_index_name "fedora/42")
  set(_supported_architectures
    "aarch64"
    "x86_64"
    "mips64el"
    "mipsel"
    "ppc64le"
    "s390x"
  )
  check_architecture_support()
endfunction()
