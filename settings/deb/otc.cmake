macro(set_otc_deb_settings)
  # Set the list of config files to prevent package upgrades from replacing
  # config files by default
  set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${ASSETS_DIR}/deb/conffiles")
endmacro()
