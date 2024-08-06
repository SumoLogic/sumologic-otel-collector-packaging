set(package_name "otelcol-sumo-fips")
set(package_os "linux")
set(package_arch "aarch64")
set(goos "linux")
set(goarch "arm64")
set(fips 1)

set_common_settings()
set_otc_settings()
set_common_rpm_settings()
set_otc_rpm_settings()

default_otc_linux_install()
install_otc_service_systemd()

build_rpm_cpack_config()
