macro(default_otc_selinux_linux_install)
  install_otc_selinux_pp_bz2()
endmacro()

# e.g. /usr/share/selinux/packages/otelcol-sumo.pp.bz2
macro(install_otc_selinux_pp_bz2)
  require_variables(
    "otc_selinux_component"
  )
  install(
    FILES "${OTC_SELINUX_ASSETS_DIR}/sepolicy/otelcol-sumo.pp.bz2"
    DESTINATION usr/share/selinux/packages
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ
      WORLD_READ
    COMPONENT ${otc_selinux_component}
  )
endmacro()
