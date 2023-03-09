macro(set_otc_productbuild_settings)
  require_variables(
    "ASSETS_DIR"
    "PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR"
  )

  # Render productbuild hook templates
  render_productbuild_hook_templates()

  # Copy the license file to the build directory and change the extension to be
  # compatible with productbuild
  file(
    COPY "${ASSETS_DIR}/LICENSE"
    DESTINATION "${CMAKE_BINARY_DIR}"
  )
  file(RENAME "${CMAKE_BINARY_DIR}/LICENSE" "${CMAKE_BINARY_DIR}/LICENSE.txt")

  set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_BINARY_DIR}/LICENSE.txt")

  # CPACK_PREFLIGHT_<COMP>_SCRIPT
  #   Full path to a file that will be used as the preinstall script for the
  #   named <COMP> component's package, where <COMP> is the uppercased component
  #   name. No preinstall script is added if this variable is not defined for a
  #   given component.
  set(CPACK_PREFLIGHT_OTELCOL-SUMO_SCRIPT "${PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR}/preflight")

  # CPACK_POSTFLIGHT_<COMP>_SCRIPT
  #   Full path to a file that will be used as the postinstall script for the
  #   named <COMP> component's package, where <COMP> is the uppercased component
  #   name. No postinstall script is added if this variable is not defined for a
  #   given component.
  set(CPACK_POSTFLIGHT_OTELCOL-SUMO_SCRIPT "${PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR}/postflight")

  # Add the list of config files to prevent package upgrades from replacing
  # config files by default
  #list(APPEND CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${ASSETS_DIR}/deb/conffiles")

  set(SOURCE_OTC_UNINSTALL_SCRIPT_PATH "${ASSETS_DIR}/productbuild/uninstall.sh")
  set(OTC_APP_SUPPORT_DIR "Library/Application Support/otelcol-sumo")
endmacro()
