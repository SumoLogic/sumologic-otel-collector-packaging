##
# Debian releases
#
# LTS: https://wiki.debian.org/LTS.
# Extended LTS: https://wiki.debian.org/LTS/Extended
# Debian Releases: https://www.debian.org/releases/
##

# Debian 12 Bookworm
#
# End of LTS Support: 2028-06-11
# End of Extended LTS Support: 2033-06-30
function(debian_bookworm)
  set(_distro_name "Debian 12 Bookworm")
  set(_distro_index_name "debian/bookworm")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armel"
    "armhf"
    "i386"
    "mipsel"
    "mips64el"
    "ppc64el"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Debian 11 Bullseye
#
# End of LTS Support: 2026-08-31
# End of Extended LTS Support: 2031-06-30
function(debian_bullseye)
  set(_distro_name "Debian 11 Bullseye")
  set(_distro_index_name "debian/bullseye")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armel"
    "armhf"
    "i386"
    "mipsel"
    "mips64el"
    "ppc64el"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Debian 10 Buster
#
# End of LTS Support: 2024-06-30
# End of Extended LTS Support: 2029-06-30
function(debian_buster)
  set(_distro_name "Debian 10 Buster")
  set(_distro_index_name "debian/buster")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armel"
    "armhf"
    "i386"
    "mips"
    "mipsel"
    "mips64el"
    "ppc64el"
    "s390x"
  )
  check_architecture_support()
endfunction()

# Debian 9 Stretch
#
# End of LTS Support: 2022-06-30
# End of Extended LTS Support: 2027-06-30
function(debian_stretch)
  set(_distro_name "Debian 9 Stretch")
  set(_distro_index_name "debian/stretch")
  set(_supported_architectures
    "amd64"
    "arm64"
    "armel"
    "armhf"
    "i386"
    "mips"
    "mips64el"
    "mipsel"
    "ppc64el"
    "s390x"
  )
  check_architecture_support()
endfunction()
