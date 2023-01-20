function(package_otc_selinux_linux_noarch_rpm)
  set(target_name "package-otelcol-sumo-selinux-linux-noarch-rpm")
  set(package_os "linux")
  set(package_arch "noarch")
  set(otc_selinux_component "${target_name}")

  set_common_settings()
  set_otc_selinux_settings()
  set_common_rpm_settings()
  set_otc_selinux_rpm_settings()

  default_otc_selinux_linux_install()

  build_rpm_cpack_config()
endfunction()
