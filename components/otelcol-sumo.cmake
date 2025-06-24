macro(default_otc_linux_install)
  install_otc_config_directory()
  install_otc_config_fragment_directory()
  install_otc_config_fragments_available_directory()
  install_otc_config_examples()
  install_otc_user_env_directory()
  install_otc_opampd_directory()
  install_otc_state_directory()
  install_otc_filestorage_state_directory()
  install_otc_sumologic_yaml()
  install_otc_linux_hostmetrics_yaml()
  install_otc_ephemeral_yaml()
  install_otc_timezone_yaml()
  install_otc_token_env()
  install_otc_binary()
  install_otc_config_binary()
endmacro()

macro(default_otc_darwin_install)
  install_otc_config_directory()
  install_otc_config_fragment_directory()
  install_otc_config_fragments_available_directory()
  install_otc_config_examples()
  install_otc_opampd_directory()
  install_otc_state_directory()
  install_otc_filestorage_state_directory()
  install_otc_log_directory()
  install_otc_sumologic_yaml()
  install_otc_darwin_hostmetrics_yaml()
  install_otc_ephemeral_yaml()
  install_otc_timezone_yaml()
  install_otc_binary()
  install_otc_config_binary()
  install_otc_uninstall_script()
endmacro()

macro(create_otc_components)
  cpack_add_component_group("otelcol-sumo-group"
    DISPLAY_NAME "OpenTelemetry Collector"
    EXPANDED
  )

  cpack_add_component("otelcol-sumo"
    DISPLAY_NAME "Application Files"
    REQUIRED
    GROUP "otelcol-sumo-group"
  )
endmacro()

# e.g. /etc/otelcol-sumo
macro(install_otc_config_directory)
  require_variables(
    "OTC_CONFIG_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_CONFIG_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
      WORLD_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d
macro(install_otc_config_fragment_directory)
  require_variables(
    "OTC_CONFIG_FRAGMENTS_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_CONFIG_FRAGMENTS_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d-available
macro(install_otc_config_fragments_available_directory)
  require_variables(
    "OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d-available/examples
macro(install_otc_config_examples)
  require_variables(
    "OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR"
    "ASSETS_DIR"
  )

  install(
    DIRECTORY
    DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}/examples"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )

  file(GLOB_RECURSE examples CONFIGURE_DEPENDS "${ASSETS_DIR}/conf.d/examples/*.yaml.example")

  foreach(example ${examples})
    install(
      FILES "${example}"
      DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}/examples"
      PERMISSIONS
        OWNER_READ OWNER_WRITE
        GROUP_READ GROUP_WRITE
      COMPONENT otelcol-sumo
    )
  endforeach(example)
endmacro()

# e.g. /etc/otelcol-sumo/env
macro(install_otc_user_env_directory)
  require_variables(
    "OTC_USER_ENV_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_USER_ENV_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/opamp.d
macro(install_otc_opampd_directory)
  require_variables(
    "OTC_OPAMPD_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_OPAMPD_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /var/lib/otelcol-sumo
macro(install_otc_state_directory)
  require_variables(
    "OTC_STATE_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_STATE_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /var/lib/otelcol-sumo/file_storage
macro(install_otc_filestorage_state_directory)
  require_variables(
    "OTC_FILESTORAGE_STATE_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_FILESTORAGE_STATE_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /var/log/otelcol-sumo
macro(install_otc_log_directory)
  require_variables(
    "OTC_LOG_DIR"
  )
  install(
    DIRECTORY
    DESTINATION "${OTC_LOG_DIR}"
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /usr/local/bin/otelcol-sumo
macro(install_otc_binary)
  require_variables(
    "OTC_BIN_DIR"
    "OTC_BIN"
    "REMOTE_OTC_BIN_PATH"
  )

  install(
    FILES "${REMOTE_OTC_BIN_PATH}"
    DESTINATION "${OTC_BIN_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    RENAME "${OTC_BIN}"
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /usr/local/bin/otelcol-config
macro(install_otc_config_binary)
  require_variables(
    "OTC_BIN_DIR"
    "OTC_CONFIG_BIN"
    "REMOTE_OTC_CONFIG_BIN_PATH"
  )

  install(
    FILES "${REMOTE_OTC_CONFIG_BIN_PATH}"
    DESTINATION "${OTC_BIN_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    RENAME "${OTC_CONFIG_BIN}"
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /Libary/Application Support/otelcol-sumo/uninstall.sh
macro(install_otc_uninstall_script)
  require_variables(
    "OTC_APP_SUPPORT_DIR"
    "SOURCE_OTC_UNINSTALL_SCRIPT_PATH"
  )

  install(
    FILES "${SOURCE_OTC_UNINSTALL_SCRIPT_PATH}"
    DESTINATION "${OTC_APP_SUPPORT_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/sumologic.yaml
macro(install_otc_sumologic_yaml)
  require_variables(
    "ASSETS_DIR"
    "OTC_CONFIG_DIR"
    "OTC_SUMOLOGIC_CONFIG"
  )
  install(
    FILES "${ASSETS_DIR}/sumologic.yaml"
    DESTINATION "${OTC_CONFIG_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ GROUP_WRITE
    RENAME "${OTC_SUMOLOGIC_CONFIG}"
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/env/token.env
macro(install_otc_token_env)
  require_variables(
    "ASSETS_DIR"
    "OTC_USER_ENV_DIR"
  )
  install(
    FILES "${ASSETS_DIR}/env/token.env"
    DESTINATION "${OTC_USER_ENV_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ GROUP_WRITE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d-available/hostmetrics.yaml
macro(install_otc_darwin_hostmetrics_yaml)
  require_variables(
    "ASSETS_DIR"
    "OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR"
  )
  install(
    FILES "${ASSETS_DIR}/conf.d/darwin.yaml"
    DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}"
    RENAME "hostmetrics.yaml"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ GROUP_WRITE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d-available/hostmetrics.yaml
macro(install_otc_linux_hostmetrics_yaml)
  require_variables(
    "ASSETS_DIR"
    "OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR"
  )
  install(
    FILES "${ASSETS_DIR}/conf.d/linux.yaml"
    DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}"
    RENAME "hostmetrics.yaml"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ GROUP_WRITE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d-available/ephemeral.yaml
macro(install_otc_ephemeral_yaml)
  require_variables(
    "ASSETS_DIR"
    "OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR"
  )
  install(
    FILES "${ASSETS_DIR}/conf.d/ephemeral.yaml"
    DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ GROUP_WRITE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d-available/timezone.yaml
macro(install_otc_timezone_yaml)
  require_variables(
    "ASSETS_DIR"
    "OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR"
  )
  install(
    FILES "${ASSETS_DIR}/conf.d/timezone.yaml"
    DESTINATION "${OTC_CONFIG_FRAGMENTS_AVAILABLE_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ GROUP_WRITE
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /lib/systemd/system/sumologic.yaml
macro(install_otc_service_systemd)
  require_variables(
    "ASSETS_DIR"
    "OTC_SYSTEMD_CONFIG"
    "OTC_SYSTEMD_DIR"
  )
  install_otc_service_script()
  install(
    FILES "${ASSETS_DIR}/services/systemd/${OTC_SYSTEMD_CONFIG}"
    DESTINATION "${OTC_SYSTEMD_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ
      WORLD_READ
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /Library/LaunchDaemons/com.sumologic.otelcol-sumo.plist
macro(install_otc_service_launchd)
  require_variables(
    "ASSETS_DIR"
    "OTC_LAUNCHD_CONFIG"
    "OTC_LAUNCHD_DIR"
  )
  install_otc_service_script()
  install(
    FILES "${ASSETS_DIR}/services/launchd/${OTC_LAUNCHD_CONFIG}"
    DESTINATION "${OTC_LAUNCHD_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ
    COMPONENT otelcol-sumo
  )
endmacro()

# e.g. /usr/share/otelcol-sumo/otelcol-sumo.sh
macro(install_otc_service_script)
  require_variables(
    "ASSETS_DIR"
    "OTC_SERVICE_SCRIPT"
    "OTC_SHARE_DIR"
  )
  install(
    FILES "${ASSETS_DIR}/${OTC_SERVICE_SCRIPT}"
    DESTINATION "${OTC_SHARE_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    COMPONENT otelcol-sumo
  )
endmacro()
