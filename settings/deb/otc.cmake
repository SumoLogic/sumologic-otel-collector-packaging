macro(set_otc_deb_settings)
  require_variables(
    "ASSETS_DIR"
    "DEB_HOOK_TEMPLATES_OUTPUT_DIR"
  )

  # Render deb hook templates
  render_deb_hook_templates()

  # Create a new list for package control extras
  set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "")

  # Add the list of config files to prevent package upgrades from replacing
  # config files by default
  list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${ASSETS_DIR}/deb/conffiles")

  # Add the package hook scripts
  list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${DEB_HOOK_TEMPLATES_OUTPUT_DIR}/preinst"
    "${DEB_HOOK_TEMPLATES_OUTPUT_DIR}/postinst"
    "${DEB_HOOK_TEMPLATES_OUTPUT_DIR}/prerm"
    "${DEB_HOOK_TEMPLATES_OUTPUT_DIR}/postrm"
  )
endmacro()
