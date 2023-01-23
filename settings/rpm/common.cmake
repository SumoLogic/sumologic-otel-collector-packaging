macro(set_common_rpm_settings)
  require_variables(
    "package_arch"
  )

  set(CPACK_GENERATOR "RPM")
  set(CPACK_RPM_PACKAGE_ARCHITECTURE "${package_arch}")
  set(CPACK_RPM_PACKAGE_LICENSE "Apache-2.0")
endmacro()
