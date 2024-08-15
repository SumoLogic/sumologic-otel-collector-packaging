macro(set_otc_selinux_settings)
  require_variables(
    "ASSETS_DIR"
    "OTC_SELINUX_ASSETS_DIR"
    "OTC_VERSION"
    "package_arch"
  )

  ##
  # Required and optional programs
  #
  # Attempts to find required and optional programs used to build the packages.
  ##
  find_program(BZIP2_PROGRAM bzip2 REQUIRED)

  ##
  # Destination file & directory names & paths
  #
  # Specifies the names & paths of files & directories which the packages will
  # create or install.
  ##

  # File names
  set(OTC_SELINUX_PP_NAME "otelcol-sumo.pp")

  # Directories
  set(OTC_SELINUX_ASSETS_DIR "${ASSETS_DIR}/otc_selinux")
  set(OTC_SELINUX_PACKAGES_DIR "usr/share/selinux/packages")
  set(OTC_SELINUX_DISTRIBUTED_DIR "${OTC_SELINUX_PACKAGES_DIR}/devel/include/distributed")
  set(OTC_SELINUX_TARGETED_DIR "${OTC_SELINUX_PACKAGES_DIR}/targeted")
  set(OTC_SELINUX_SEPOLICY_DIR "${OTC_SELINUX_ASSETS_DIR}/sepolicy")

  # File paths
  set(OTC_SELINUX_PP_SOURCE_PATH "${OTC_SELINUX_SEPOLICY_DIR}/${OTC_SELINUX_PP_NAME}")

  # CPack configuration
  set(CPACK_PACKAGE_NAME "otelcol-sumo-selinux")
  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${package_arch}")
  set(CPACK_RESOURCE_FILE_LICENSE "${ASSETS_DIR}/LICENSE")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${OTC_SELINUX_ASSETS_DIR}/description")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "SELinux policies for otelcol-sumo")
endmacro()
