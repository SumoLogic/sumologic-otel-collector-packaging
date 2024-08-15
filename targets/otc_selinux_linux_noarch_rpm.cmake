set(package_name "otelcol-sumo-selinux")
set(package_os "linux")
set(package_arch "noarch")

set_common_settings()
set_otc_selinux_settings()
set_common_rpm_settings()
set_otc_selinux_rpm_settings()

default_otc_selinux_linux_install()

build_otc_selinux_rpm_cpack_config()
