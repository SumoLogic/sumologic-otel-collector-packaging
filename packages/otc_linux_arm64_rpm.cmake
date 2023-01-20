function(package_otc_linux_arm64_rpm)
  set(target_name "package-otelcol-sumo-linux-arm64-rpm")
  set(package_os "linux")
  set(package_arch "aarch64")
  set(goos "linux")
  set(goarch "arm64")
  set(otc_component "${target_name}")

  set_common_settings()
  set_otc_settings()
  set_common_rpm_settings()
  set_otc_rpm_settings()

  default_otc_linux_install()
  install_otc_service_systemd()

  build_rpm_cpack_config()
endfunction()
