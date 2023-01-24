macro(set_common_rpm_settings)
  require_variables(
    "BUILD_NUMBER"
    "PROJECT_VERSION"
    "package_name"
    "package_arch"
  )

  set(CPACK_GENERATOR "RPM")
  set(CPACK_RPM_PACKAGE_ARCHITECTURE "${package_arch}")
  set(CPACK_RPM_PACKAGE_LICENSE "Apache-2.0")
  set(PACKAGE_FILE_EXTENSION "rpm")

  set(CPACK_PACKAGE_FILE_NAME "${package_name}-${PROJECT_VERSION}-${BUILD_NUMBER}.${package_arch}")
  if (DEFINED goarm)
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-armv${goarm}")
  endif()
  if (DEFINED gomips)
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${gomips}")
  endif()
  if (DEFINED gomips64)
    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_FILE_NAME}-${gomips64}")
  endif()
endmacro()
