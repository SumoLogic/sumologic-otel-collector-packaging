macro(default_otc_selinux_linux_install)
  install_otc_selinux_pp_bz2()
  install_otc_selinux_if()
endmacro()

# e.g. /usr/share/selinux/packages/targeted/otelcol-sumo.pp.bz2
macro(install_otc_selinux_pp_bz2)
  require_variables(
    "OTC_SELINUX_PP_NAME"
    "OTC_SELINUX_SEPOLICY_DIR"
    "OTC_SELINUX_TARGETED_DIR"
  )
  install(
    FILES "${OTC_SELINUX_SEPOLICY_DIR}/${OTC_SELINUX_PP_NAME}.bz2"
    DESTINATION "${OTC_SELINUX_TARGETED_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ
      WORLD_READ
    COMPONENT otelcol-sumo-selinux
  )
endmacro()

# e.g. /usr/share/selinux/devel/include/distributed/otelcol-sumo.if
macro(install_otc_selinux_if)
  require_variables(
    "OTC_SELINUX_DISTRIBUTED_DIR"
    "OTC_SELINUX_SEPOLICY_DIR"
  )
  install(
    FILES "${OTC_SELINUX_SEPOLICY_DIR}/otelcol-sumo.if"
    DESTINATION "${OTC_SELINUX_DISTRIBUTED_DIR}"
    PERMISSIONS
      OWNER_READ OWNER_WRITE
      GROUP_READ
      WORLD_READ
    COMPONENT otelcol-sumo-selinux
  )
endmacro()
