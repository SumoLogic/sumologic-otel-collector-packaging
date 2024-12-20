macro(set_otc_settings)
  require_variables(
    "OTC_VERSION"
    "OTC_SUMO_VERSION"
    "goos"
    "goarch"
    "package_arch"
  )

  ##
  # Destination file & directory names & paths
  #
  # Specifies the names & paths of files & directories which the packages will
  # create or install.
  ##

  # File names
  set(OTC_BIN "otelcol-sumo")
  set(OTC_CONFIG_BIN "otelcol-config")
  set(OTC_SUMOLOGIC_CONFIG "sumologic.yaml")
  set(OTC_SYSTEMD_CONFIG "otelcol-sumo.service")
  set(OTC_SERVICE_SCRIPT "otelcol-sumo.sh")
  set(OTC_LAUNCHD_CONFIG "com.sumologic.otelcol-sumo.plist")

  # Directories
  set(OTC_BIN_DIR "usr/local/bin")
  set(OTC_CONFIG_DIR "etc/otelcol-sumo")
  set(OTC_CONFIG_FRAGMENTS_DIR "${OTC_CONFIG_DIR}/conf.d")
  set(OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR "${OTC_CONFIG_DIR}/conf.d-available")
  set(OTC_USER_ENV_DIR "${OTC_CONFIG_DIR}/env")
  set(OTC_OPAMPD_DIR "${OTC_CONFIG_DIR}/opamp.d")
  set(OTC_STATE_DIR "var/lib/otelcol-sumo")
  set(OTC_FILESTORAGE_STATE_DIR "${OTC_STATE_DIR}/file_storage")
  set(OTC_LAUNCHD_DIR "Library/LaunchDaemons")
  set(OTC_SYSTEMD_DIR "lib/systemd/system")
  set(OTC_LOG_DIR "var/log/otelcol-sumo")
  set(OTC_SHARE_DIR "usr/share/otelcol-sumo")
  if("${goos}" STREQUAL "darwin")
    set(OTC_SHARE_DIR "usr/local/share/otelcol-sumo")
  endif()

  # File paths
  set(OTC_BIN_PATH "${OTC_BIN_DIR}/${OTC_BIN}")
  set(OTC_SUMOLOGIC_CONFIG_PATH "${OTC_CONFIG_DIR}/${OTC_SUMOLOGIC_CONFIG}")

  ##
  # Local & remote file & directory names & paths
  #
  # Specifies the names & paths of local & remote files required to build the
  # packages.
  ##

  # Remote file names
  set(REMOTE_OTC_BIN "otelcol-sumo")
  set(REMOTE_OTC_CONFIG_BIN "otelcol-config")
  if(fips)
    set(REMOTE_OTC_BIN "${REMOTE_OTC_BIN}-fips")
    set(REMOTE_OTC_CONFIG_BIN "${REMOTE_OTC_CONFIG_BIN}-fips")
  endif()
  set(REMOTE_OTC_BIN "${REMOTE_OTC_BIN}-${goos}_${goarch}")
  set(REMOTE_OTC_CONFIG_BIN "${REMOTE_OTC_CONFIG_BIN}-${goos}_${goarch}")

  # Remote file paths
  set(REMOTE_OTC_BIN_PATH "${CMAKE_BINARY_DIR}/${REMOTE_OTC_BIN}")
  set(REMOTE_OTC_CONFIG_BIN_PATH "${CMAKE_BINARY_DIR}/${REMOTE_OTC_CONFIG_BIN}")

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
  set(CPACK_PACKAGE_NAME "${package_name}")
  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${package_arch}")
  set(CPACK_RESOURCE_FILE_LICENSE "${ASSETS_DIR}/LICENSE")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${ASSETS_DIR}/description")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "An agent to send logs, metrics and traces to Sumo Logic")
endmacro()
