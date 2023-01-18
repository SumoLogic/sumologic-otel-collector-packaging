macro(default_otc_linux_install)
  install_otc_config_directory()
  install_otc_config_fragment_directory()
  install_otc_state_directory()
  install_otc_filestorage_state_directory()
  install_otc_sumologic_yaml()
  install_otc_binary()
endmacro()

# e.g. /etc/otelcol-sumo
macro(install_otc_config_directory)
  install(
    DIRECTORY
    DESTINATION ${OTC_CONFIG_DIR}
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
    COMPONENT ${otc_component}
  )
endmacro()

# e.g. /etc/otelcol-sumo/conf.d
macro(install_otc_config_fragment_directory)
  require_variables(
    "otc_component"
  )
  install(
    DIRECTORY
    DESTINATION ${OTC_CONFIG_FRAGMENTS_DIR}
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_WRITE GROUP_EXECUTE
    COMPONENT ${otc_component}
  )
endmacro()

# e.g. /var/lib/otelcol-sumo
macro(install_otc_state_directory)
  require_variables(
    "otc_component"
  )
  install(
    DIRECTORY
    DESTINATION ${OTC_STATE_DIR}
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
    COMPONENT ${otc_component}
  )
endmacro()

# e.g. /var/lib/otelcol-sumo/file_storage
macro(install_otc_filestorage_state_directory)
  require_variables(
    "otc_component"
  )
  install(
    DIRECTORY
    DESTINATION ${OTC_FILESTORAGE_STATE_DIR}
    DIRECTORY_PERMISSIONS
      OWNER_READ OWNER_WRITE OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
    COMPONENT ${otc_component}
  )
endmacro()

# e.g. /usr/local/bin/otelcol-sumo
macro(install_otc_binary)
  require_variables(
    "otc_component"
  )

  # TODO: retrieve this from the external project somehow or create a helper to
  # DRY this up a bit
  set(otc_binary_dir "${CMAKE_BINARY_DIR}/external_projects/otelcol-sumo")
  if(FIPS_ENABLED)
    set(otc_binary_dir "${otc_binary_dir}-fips")
  endif()
  set(otc_binary_dir "${otc_binary_dir}-${goos}-${goarch}")

  install(
    FILES "${otc_binary_dir}/otelcol-sumo"
    DESTINATION "${OTC_BIN_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_EXECUTE
      GROUP_READ GROUP_EXECUTE
      WORLD_READ WORLD_EXECUTE
    RENAME ${OTC_BINARY}
    COMPONENT "${otc_component}"
  )
endmacro()

# e.g. /etc/otelcol-sumo/sumologic.yaml
macro(install_otc_sumologic_yaml)
  require_variables(
    "otc_component"
  )
  install(
    FILES "${ASSETS_DIR}/sumologic.yaml"
    DESTINATION "${OTC_CONFIG_DIR}"
    PERMISSIONS
      OWNER_READ
      GROUP_READ
    RENAME "${OTC_SUMOLOGIC_CONFIG}"
    COMPONENT "${otc_component}"
  )
endmacro()

macro(install_otc_service_systemd)
  require_variables(
    "otc_component"
  )
  install(
    FILES "${ASSETS_DIR}/systemd/otelcol-sumo.service"
    DESTINATION "${OTC_SYSTEMD_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ
      WORLD_READ
    COMPONENT "${otc_component}"
  )
endmacro()
