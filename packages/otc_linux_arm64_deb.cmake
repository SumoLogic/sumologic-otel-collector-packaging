function(package_otc_linux_arm64_deb)
  set(target_name "package-otelcol-sumo-linux-arm64-deb")
  set(package_os "linux")
  set(package_arch "arm64")
  set(goos "linux")
  set(goarch "arm64")
  set(otc_component "${target_name}")

  set_common_settings()
  set_otc_settings()
  set_common_deb_settings()
  set_otc_deb_settings()

  default_otc_linux_install()
  install_otc_service_systemd()

  build_deb_cpack_config()
endfunction()
