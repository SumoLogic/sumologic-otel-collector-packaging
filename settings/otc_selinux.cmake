macro(set_otc_selinux_settings)
  require_variables(
    "otc_selinux_component"
  )

  # Local directory paths
  set(OTC_SELINUX_ASSETS_DIR "${ASSETS_DIR}/otc_selinux")

  # CPack configuration
  set(CPACK_PACKAGE_NAME "otelcol-sumo-selinux")
  set(PACKAGE_SHORT_NAME "otelcol-sumo-selinux")

  set(CPACK_COMPONENTS_ALL "${otc_selinux_component}")
  set(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};otelcol-sumo;${CPACK_COMPONENTS_ALL};/")

  set(CPACK_RESOURCE_FILE_LICENSE "${ASSETS_DIR}/LICENSE")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${OTC_SELINUX_ASSETS_DIR}/description")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "SELinux policies for otelcol-sumo")

  # Set target dependencies of the cpack target for this package. The
  # otelcol-sumo binary matching the GOOS, GOARCH and FIPS flag are required for
  # OTC packages.
  #set(target_dependencies
  #  "${otelcol_sumo_target}"
  #)
endmacro()
