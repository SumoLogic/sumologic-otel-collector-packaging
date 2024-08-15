macro(set_common_productbuild_settings)
  require_variables(
    "BUILD_NUMBER"
    "PROJECT_VERSION"
    "package_name"
    "package_arch"
  )

  set(CPACK_GENERATOR "productbuild")
  set(PACKAGE_FILE_EXTENSION "pkg")
  set(CPACK_PACKAGE_INSTALL_DIRECTORY "/")
  set(CPACK_PACKAGE_DEFAULT_LOCATION "/")

  set(CPACK_PRODUCTBUILD_IDENTIFIER "com.sumologic")

  # These options currently have no affect on the produced Distribution file as
  # we are using our own CPack.distribution.dist.in template. This should be
  # uncommented once the default template supports the features we need such as
  # the hostArchitectures & customize options and disabling welcome & readme
  # files.
  #set(CPACK_PRODUCTBUILD_DOMAINS true)
  #set(CPACK_PRODUCTBUILD_DOMAINS_ANYWHERE false)
  #set(CPACK_PRODUCTBUILD_DOMAINS_USER false)
  #set(CPACK_PRODUCTBUILD_DOMAINS_ROOT true)

  set(CPACK_PACKAGE_FILE_NAME "${package_name}_${PROJECT_VERSION}-${BUILD_NUMBER}-${package_arch}")
endmacro()
