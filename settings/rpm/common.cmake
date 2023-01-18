macro(set_common_rpm_settings)
  set(CPACK_GENERATOR "RPM")
  # set(CPACK_RPM_COMPONENT_INSTALL ON)
  # set(CPACK_RPM_PACKAGE_GROUP "System Environment/Daemons")
  # set(CPACK_RPM_PACKAGE_LICENSE "Apache v2.0")
  # set(CPACK_RPM_PACKAGE_RELEASE ${CPACK_PACKAGE_RELEASE})
  # set(CPACK_RPM_SPEC_MORE_DEFINE "%define ignore \#")
  # set(CPACK_RPM_runtime_USER_FILELIST
  #   "%config(noreplace) /etc/otelcol-sumo/sumologic.yaml"
  #   "%ignore /etc"
  #   "%ignore /lib"
  #   "%ignore /lib/systemd"
  #   "%ignore /lib/systemd/system"
  #   "%ignore /usr/local"
  #   "%ignore /usr/local/bin"
  #   "%ignore /var"
  #   "%ignore /var/lib"
  # )
  # set(CPACK_RPM_PACKAGE_AUTOREQ ON)
  # set(CPACK_RPM_runtime_PACKAGE_NAME "${CPACK_PACKAGE_NAME}")
  # set(CPACK_RPM_runtime_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_PACKAGE_RELEASE}.${CMAKE_SYSTEM_PROCESSOR}.rpm")
endmacro()
