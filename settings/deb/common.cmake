macro(set_common_deb_settings)
  require_variables(
    "ASSETS_DIR"
    "BUILD_NUMBER"
    "PROJECT_VERSION"
    "package_name"
    "package_arch"
  )

  set(CPACK_GENERATOR "DEB")
  set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${package_arch}")
  set(PACKAGE_FILE_EXTENSION "deb")
  set(CPACK_DEBIAN_PACKAGE_RELEASE "${BUILD_NUMBER}")

  set(CPACK_PACKAGE_FILE_NAME "${package_name}_${PROJECT_VERSION}-${BUILD_NUMBER}_${package_arch}")
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
