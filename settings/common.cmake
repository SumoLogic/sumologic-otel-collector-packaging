macro(set_common_settings)
  set(CMAKE_INSTALL_PREFIX "/")

  set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
  set(CPACK_PACKAGE_RELEASE "${BUILD_NUMBER}")
  set(CPACK_PACKAGE_CONTACT "Sumo Logic Support <support@sumologic.com>")
  set(CPACK_PACKAGE_VENDOR "Sumo Logic")
  set(CPACK_PACKAGING_INSTALL_PREFIX "/")
endmacro()
