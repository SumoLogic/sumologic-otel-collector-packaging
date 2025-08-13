##
# Ubuntu releases
#
# Release Lifecycle: https://ubuntu.com/about/release-cycle
# System Requirements: https://ubuntu.com/server/docs/system-requirements
# Supported Architectures: https://help.ubuntu.com/community/SupportedArchitectures
# Netboot images: https://cdimage.ubuntu.com/netboot/14.04/
##

# Ubuntu 24.04 LTS Noble Numbat
#
# End of Standard Support: April 2029
# End of Ubuntu Pro Support: April 2034
# End of Legacy Support: April 2036
function(ubuntu_noble)
  set(_distro_name "Ubuntu 24.04 Noble Numbat")
  set(_distro_index_name "ubuntu/noble")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armhf"
    "ppc64el"
    "riscv64"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Ubuntu 22.04 LTS Jammy Jellyfish
#
# End of Standard Support: April 2027
# End of Ubuntu Pro Support: April 2032
# End of Legacy Support: April 2034
function(ubuntu_jammy)
  set(_distro_name "Ubuntu 22.04 Jammy Jellyfish")
  set(_distro_index_name "ubuntu/jammy")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armhf"
    "ppc64el"
    "riscv64"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Ubuntu 20.04 LTS Focal Fossa
#
# End of Standard Support: April 2025
# End of Ubuntu Pro Support: April 2030
# End of Legacy Support: April 2032
function(ubuntu_focal)
  set(_distro_name "Ubuntu 20.04 Focal Fossa")
  set(_distro_index_name "ubuntu/focal")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armhf"
    "ppc64el"
    "riscv64"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Ubuntu 18.04 LTS Bionic Beaver
#
# End of Standard Support: April 2023
# End of Ubuntu Pro Support: April 2028
# End of Legacy Support: April 2030
function(ubuntu_bionic)
  set(_distro_name "Ubuntu 18.04 Bionic Beaver")
  set(_distro_index_name "ubuntu/bionic")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armhf"
    "i386"
    "ppc64el"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Ubuntu 16.04 LTS Xenial Xerus
#
# End of Standard Support: April 2021
# End of Ubuntu Pro Support: April 2026
# End of Legacy Support: April 2028
function(ubuntu_xenial)
  set(_distro_name "Ubuntu 16.04 Xenial Xerus")
  set(_distro_index_name "ubuntu/xenial")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armhf"
    "i386"
    "powerpc"
    "ppc64el"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Ubuntu 14.04 LTS Trusty Tahr
#
# End of Standard Support: April 2019
# End of Ubuntu Pro Support: April 2024
# End of Legacy Support: April 2026
function(ubuntu_trusty)
  set(_distro_name "Ubuntu 14.04 Trusty Tahr")
  set(_distro_index_name "ubuntu/trusty")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armhf"
    "armel"
    "i386"
    "powerpc"
    "ppc64el"
  )
  check_architecture_support()
endfunction()
