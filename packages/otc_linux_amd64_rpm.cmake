function(package_otc_linux_amd64_rpm)
  set(target_name "package-otelcol-sumo-linux-amd64-rpm")
  set(package_os "linux")
  set(package_arch "x86_64")
  set(goos "linux")
  set(goarch "amd64")
  set(otc_component "${target_name}")

  set_common_settings()
  set_otc_settings()
  set_common_rpm_settings()
  set_otc_rpm_settings()

  default_otc_linux_install()
  install_otc_service_systemd()

  build_rpm_cpack_config()
endfunction()
