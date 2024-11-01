# Checks if the Packagecloud distro supports the package architecture and if it
# does it will be added to the list of Packagecloud distributions to upload the
# package to.
macro(check_architecture_support)
  if(NOT ${package_arch} IN_LIST _supported_architectures)
    message(FATAL_ERROR "${_distro_name} does not support architecture: ${package_arch}")
  endif()
  list(APPEND packagecloud_distros ${_distro_index_name})
  set(packagecloud_distros ${packagecloud_distros} PARENT_SCOPE)
endmacro()

macro(print_packagecloud_distros)
  message(STATUS "Packagecloud distributions for this package:")
  foreach(_pc_distro ${packagecloud_distros})
    message(STATUS "  * ${_pc_distro}")
  endforeach()
endmacro()

include("${DISTRIBUTIONS_DIR}/amazon.cmake")
include("${DISTRIBUTIONS_DIR}/debian.cmake")
include("${DISTRIBUTIONS_DIR}/el.cmake")
include("${DISTRIBUTIONS_DIR}/fedora.cmake")
include("${DISTRIBUTIONS_DIR}/ol.cmake")
include("${DISTRIBUTIONS_DIR}/opensuse.cmake")
include("${DISTRIBUTIONS_DIR}/raspbian.cmake")
include("${DISTRIBUTIONS_DIR}/sles.cmake")
include("${DISTRIBUTIONS_DIR}/ubuntu.cmake")
