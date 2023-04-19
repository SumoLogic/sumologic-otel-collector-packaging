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

  set(CPACK_PREFLIGHT_OTELCOL-SUMO_SCRIPT "${PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR}/preflight")
  set(CPACK_POSTFLIGHT_OTELCOL-SUMO_SCRIPT "${PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR}/postflight")

  set(SOURCE_OTC_UNINSTALL_SCRIPT_PATH "${ASSETS_DIR}/productbuild/uninstall.sh")
  set(OTC_APP_SUPPORT_DIR "Library/Application Support/otelcol-sumo")
endmacro()
