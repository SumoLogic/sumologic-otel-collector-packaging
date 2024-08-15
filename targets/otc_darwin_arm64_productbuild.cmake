set(package_name "otelcol-sumo")
set(package_os "darwin")
set(package_arch "apple")
set(supported_archs "arm64")
set(goos "darwin")
set(goarch "arm64")

set_common_settings()
set_otc_settings()
set_common_productbuild_settings()
set_otc_productbuild_settings()

default_otc_darwin_install()
install_otc_service_launchd()

build_otc_productbuild_cpack_config()
