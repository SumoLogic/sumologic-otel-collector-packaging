macro(set_otc_rpm_settings)
  set(CPACK_RPM_USER_FILELIST
    # Mark sumologic.yaml as a config file to prevent package upgrades from
    # replacing the file by default
    "%config(noreplace) /etc/otelcol-sumo/sumologic.yaml"
  )

  # Exclude these directories from the RPM as they should already exist and
  # differing ownership/permissions can prevent installation
  set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION
    "/lib"
    "/lib/systemd"
    "/lib/systemd/system"
    "/usr/local"
    "/usr/local/bin"
    "/var"
    "/var/lib"
  )
endmacro()
