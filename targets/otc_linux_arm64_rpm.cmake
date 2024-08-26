set(package_name "otelcol-sumo")
set(package_os "linux")
set(package_arch "aarch64")
set(goos "linux")
set(goarch "arm64")

# Supported Amazon Linux versions
amazon_2()
amazon_2023()

# Supported Enterprise Linux versions
el_7()
el_8()
el_9()

# Supported Fedora versions
fedora_39()
fedora_40()

# Supported openSUSE versions
opensuse_15_5()
opensuse_15_6()

# Supported Oracle Linux versions
ol_7()
ol_8()
ol_9()

# Supported SUSE Linux Enterprise Server versions
sles_12_5()
sles_15_2()
sles_15_3()
sles_15_4()
sles_15_5()
sles_15_6()

set_common_settings()
set_otc_settings()
set_common_rpm_settings()
set_otc_rpm_settings()

default_otc_linux_install()
install_otc_service_systemd()

build_rpm_cpack_config()
