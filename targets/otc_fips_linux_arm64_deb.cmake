set(package_name "otelcol-sumo-fips")
set(package_os "linux")
set(package_arch "arm64")
set(goos "linux")
set(goarch "arm64")
set(fips 1)

# Supported Debian versions
debian_jessie()
debian_stretch()
debian_buster()
debian_bullseye()
debian_bookworm()

# Supported Ubuntu versions
ubuntu_trusty()
ubuntu_xenial()
ubuntu_bionic()
ubuntu_focal()
ubuntu_jammy()
ubuntu_noble()

# Supported Raspbian versions
raspbian_bullseye()
raspbian_bookworm()

set_common_settings()
set_otc_settings()
set_common_deb_settings()
set_otc_fips_deb_settings()

default_otc_linux_install()
install_otc_service_systemd()

build_deb_cpack_config()
