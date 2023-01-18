macro(set_otc_settings)
  require_variables(
    "otc_component"
  )

  # Directory paths
  set(OTC_BIN_DIR "usr/local/bin")
  set(OTC_CONFIG_DIR "etc/otelcol-sumo")
  set(OTC_CONFIG_FRAGMENTS_DIR "${OTC_CONFIG_DIR}/conf.d")
  set(OTC_STATE_DIR "var/lib/otelcol-sumo")
  set(OTC_FILESTORAGE_STATE_DIR "${OTC_STATE_DIR}/file_storage")
  set(OTC_SYSTEMD_DIR "lib/systemd/system")

  # File names
  setp(OTC_BINARY "otelcol-sumo")
  setp(OTC_SUMOLOGIC_CONFIG "sumologic.yaml")
  setp(OTC_SYSTEMD_CONFIG "otelcol-sumo.service")

  # CPack configuration
  set(CPACK_PACKAGE_NAME "otelcol-sumo")
  set(PACKAGE_SHORT_NAME "otelcol-sumo")

  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${package_arch}")
  # set(CPACK_COMPONENTS_ALL ${CPACK_COMPONENTS_ALL} binary)
  set(CPACK_COMPONENTS_ALL "${otc_component}")
  set(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};otelcol-sumo;${CPACK_COMPONENTS_ALL};/")

  set(CPACK_RESOURCE_FILE_LICENSE "${ASSETS_DIR}/LICENSE")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${ASSETS_DIR}/description")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "An agent to send logs, metrics and traces to Sumo Logic")
  # set(CPACK_COMPONENTS_GROUPING "ONE_PER_GROUP")
  # set(CPACK_COMPONENT_BINARY_GROUP "runtime")

  set(otelcol_sumo_target "otelcol-sumo")
  if(FIPS)
    set(otelcol_sumo_target "${otelcol_sumo_target}-fips")
  endif()
  set(otelcol_sumo_target "${otelcol_sumo_target}-${goos}-${goarch}")

  # Set target dependencies of the cpack target for this package. The
  # otelcol-sumo binary matching the GOOS, GOARCH and FIPS flag are required for
  # OTC packages.
  set(target_dependencies
    "${otelcol_sumo_target}"
  )
endmacro()
