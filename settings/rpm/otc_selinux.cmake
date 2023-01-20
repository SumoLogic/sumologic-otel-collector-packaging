macro(set_otc_selinux_rpm_settings)
  require_variables(
    "OTC_SELINUX_ASSETS_DIR"
  )

  # Use our own RPM spec template to enable the use of RPM macros for SELinux
  set(CPACK_RPM_USER_BINARY_SPECFILE_TEMPLATE "${OTC_SELINUX_ASSETS_DIR}/otelcol-sumo-selinux.spec.in")

  set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CPACK_RPM_PACKAGE_ARCHITECTURE}")

  # TODO: this will depend on which distro is being run -- instead, we may want
  # to check for the existence of the individual files we need to build with
  # CPack
  #set(CPACK_RPM_BUILDREQUIRES "selinux-policy-devel"

  #set(CPACK_RPM_SPEC_MORE_DEFINE "%define __spec_install_post /bin/true")

  set(CPACK_RPM_PRE_INSTALL_SCRIPT_FILE "${OTC_SELINUX_ASSETS_DIR}/scripts/pre.sh")
  set(CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${OTC_SELINUX_ASSETS_DIR}/scripts/post.sh")
  set(CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${OTC_SELINUX_ASSETS_DIR}/scripts/postun.sh")
  set(CPACK_RPM_POST_TRANS_SCRIPT_FILE "${OTC_SELINUX_ASSETS_DIR}/scripts/posttrans.sh")

  # Exclude these directories from the RPM as they should already exist and
  # differing ownership/permissions can prevent installation
  set(CPACK_RPM_EXCLUDE_FROM_AUTO_FILELIST_ADDITION
    "/usr/share/selinux"
    "/usr/share/selinux/packages"
  )
endmacro()
