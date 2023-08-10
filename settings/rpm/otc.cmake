macro(set_otc_rpm_settings)
  require_variables(
    "RPM_HOOK_TEMPLATES_OUTPUT_DIR"
  )

  # Render rpm hook templates
  render_rpm_hook_templates()

  set(CPACK_RPM_USER_FILELIST
    # Mark config files to prevent package upgrades from replacing the file by
    # default
    "%config(noreplace) /etc/otelcol-sumo/sumologic.yaml"
    "%config(noreplace) /etc/otelcol-sumo/conf.d/common.yaml"
    "%config(noreplace) /etc/otelcol-sumo/env/token.env"
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

  set(CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "${RPM_HOOK_TEMPLATES_OUTPUT_DIR}/before-install")
  set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${RPM_HOOK_TEMPLATES_OUTPUT_DIR}/after-install")
  set(CPACK_RPM_PRE_UNINSTALL_SCRIPT_FILE "${RPM_HOOK_TEMPLATES_OUTPUT_DIR}/before-remove")
  set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${RPM_HOOK_TEMPLATES_OUTPUT_DIR}/after-remove")
endmacro()
