macro(set_otc_settings)
  require_variables(
    "OTC_VERSION"
    "OTC_SUMO_VERSION"
    "goos"
    "goarch"
    "package_arch"
  )

  # OTC_GIT_TAG is used to determine which GitHub Release to fetch artifacts
  # from. If ENV{OTC_ARTIFACTS_SOURCE} is set as then OTC_GIT_TAG will be
  # ignored and the artifacts will be fetched from another source.
  set(OTC_GIT_TAG "v${OTC_VERSION}-sumo-${OTC_SUMO_VERSION}")

  ##
  # Destination file & directory names & paths
  #
  # Specifies the names & paths of files & directories which the packages will
  # create or install.
  ##

  # File names
  set(OTC_BINARY "otelcol-sumo")
  set(OTC_CONFIG_BINARY "otelcol-config")
  set(OTC_SUMOLOGIC_CONFIG "sumologic.yaml")
  set(OTC_SYSTEMD_CONFIG "otelcol-sumo.service")

  # Directories
  set(OTC_BIN_DIR "usr/local/bin")
  set(OTC_CONFIG_DIR "etc/otelcol-sumo")
  set(OTC_CONFIG_FRAGMENTS_DIR "${OTC_CONFIG_DIR}/conf.d")
  set(OTC_USER_ENV_DIR "${OTC_CONFIG_DIR}/env")
  set(OTC_STATE_DIR "var/lib/otelcol-sumo")
  set(OTC_FILESTORAGE_STATE_DIR "${OTC_STATE_DIR}/file_storage")
  set(OTC_LAUNCHD_DIR "Library/LaunchDaemons")
  set(OTC_SYSTEMD_DIR "lib/systemd/system")
  set(OTC_LOG_DIR "var/log/otelcol-sumo")

  # File paths
  set(OTC_SUMOLOGIC_CONFIG_PATH "${OTC_CONFIG_DIR}/${OTC_SUMOLOGIC_CONFIG}")

  ##
  # Source file & directory names & paths
  #
  # Specifies the names & paths of local & remote files required to build the
  # packages.
  ##

  # File names
  set(SOURCE_OTC_BINARY "otelcol-sumo-${OTC_VERSION}-sumo-${OTC_SUMO_VERSION}")
  set(SOURCE_OTC_CONFIG_BINARY "otelcol-config-${OTC_VERSION}-sumo-${OTC_SUMO_VERSION}")
  set(GH_OUTPUT_OTC_BIN "otelcol-sumo")
  set(GH_OUTPUT_OTC_CONFIG_BIN "otelcol-config")
  if(fips)
    set(SOURCE_OTC_BINARY "${SOURCE_OTC_BINARY}-fips")
    set(SOURCE_OTC_CONFIG_BINARY "${SOURCE_OTC_CONFIG_BINARY}-fips")
    set(GH_OUTPUT_OTC_BIN "${GH_OUTPUT_OTC_BIN}-fips")
    set(GH_OUTPUT_OTC_CONFIG_BIN "${GH_OUTPUT_OTC_CONFIG_BIN}-fips")
  endif()
  set(SOURCE_OTC_BINARY "${SOURCE_OTC_BINARY}-${goos}_${goarch}")
  set(SOURCE_OTC_CONFIG_BINARY "${SOURCE_OTC_CONFIG_BINARY}-${goos}_${goarch}")
  set(GH_OUTPUT_OTC_BIN "${GH_OUTPUT_OTC_BIN}-${goos}_${goarch}")
  set(GH_OUTPUT_OTC_CONFIG_BIN "${GH_OUTPUT_OTC_CONFIG_BIN}-${goos}_${goarch}")

  # Directories
  set(SOURCE_OTC_BINARY_DIR "${ARTIFACTS_DIR}/${SOURCE_OTC_BINARY}")
  set(SOURCE_OTC_CONFIG_BINARY_DIR "${ARTIFACTS_DIR}/${SOURCE_OTC_CONFIG_BINARY}")

  # File paths
  set(SOURCE_OTC_BINARY_PATH "${SOURCE_OTC_BINARY_DIR}/${OTC_BINARY}")
  set(SOURCE_OTC_CONFIG_BINARY_PATH "${SOURCE_OTC_CONFIG_BINARY_DIR}/${OTC_CONFIG_BINARY}")
  set(GH_ARTIFACT_OTC_BINARY_PATH "${GH_ARTIFACTS_DIR}/${GH_OUTPUT_OTC_BIN}")
  set(GH_ARTIFACT_OTC_CONFIG_BINARY_PATH "${GH_ARTIFACTS_DIR}/${GH_OUTPUT_OTC_CONFIG_BIN}")
  set(ACL_LOG_FILE_PATHS "/var/log")

  ##
  # Other
  ##

  # Service & User/Group
  set(SERVICE_NAME "otelcol-sumo")
  set(SERVICE_USER "otelcol-sumo")
  set(SERVICE_GROUP "otelcol-sumo")
  set(SERVICE_USER_HOME "/${OTC_STATE_DIR}")

  if("${goos}" STREQUAL "darwin")
    set(SERVICE_USER "_${SERVICE_USER}")
    set(SERVICE_GROUP "_${SERVICE_GROUP}")
  endif()

  # Render common hook templates
  render_common_hook_templates()

  # CPack configuration
  set(CPACK_PACKAGE_NAME "otelcol-sumo")
  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${package_arch}")
  set(CPACK_RESOURCE_FILE_LICENSE "${ASSETS_DIR}/LICENSE")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${ASSETS_DIR}/description")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "An agent to send logs, metrics and traces to Sumo Logic")

  # Set target dependencies of the cpack target for this package. The
  # otelcol-sumo binary matching the GOOS, GOARCH and FIPS flag are required for
  # OTC packages.
  set(target_dependencies
    "${SOURCE_OTC_BINARY}"
    "${SOURCE_OTC_CONFIG_BINARY}"
  )
endmacro()
