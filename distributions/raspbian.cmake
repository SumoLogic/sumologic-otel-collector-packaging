##
# Raspbian releases
#
# Operating Systems: https://www.raspberrypi.com/software/operating-systems/
#
# Support does not seem to exist for Raspbian. The OS download page have the
# last two releases available for download.
##

# Raspbian 12 Bookworm
function(raspbian_bookworm)
  set(_distro_name "Raspbian 12 Bookworm")
  set(_distro_index_name "raspbian/bookworm")
  set(_supported_architectures
    "arm64"
    "armhf"
  )
  check_architecture_support()
endfunction()

# Raspbian 11 Bullseye
function(raspbian_bullseye)
  set(_distro_name "Raspbian 11 Bullseye")
  set(_distro_index_name "raspbian/bullseye")
  set(_supported_architectures
    "arm64"
    "armhf"
  )
  check_architecture_support()
endfunction()
