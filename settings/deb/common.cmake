macro(set_common_deb_settings)
  require_variables(
    "ASSETS_DIR"
    "package_arch"
  )

  set(CPACK_GENERATOR "DEB")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${package_arch}")
endmacro()
