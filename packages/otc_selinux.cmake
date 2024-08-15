# Build OTC SELinux CPackConfig, create a target for building the package and add
# the target to the list of all package targets
macro(build_otc_selinux_cpack_config)
  require_variables(
    "BZIP2_PROGRAM"
    "OTC_SELINUX_PP_NAME"
    "OTC_SELINUX_SEPOLICY_DIR"
  )

  # Create a target, if the target does not yet exist, for building the SELinux
  # policy package file for otelcol-sumo
  if(TARGET "${OTC_SELINUX_PP_NAME}")
    message(STATUS "Target already exists: ${OTC_SELINUX_PP_NAME}")
  else()
    message(STATUS "Creating target: ${OTC_SELINUX_PP_NAME}")
    add_custom_target("${OTC_SELINUX_PP_NAME}"
      ALL
      WORKING_DIRECTORY "${OTC_SELINUX_SEPOLICY_DIR}"
      BYPRODUCTS
        ${OTC_SELINUX_PP_NAME}
        ${OTC_SELINUX_PP_NAME}.bz2
      COMMAND ${CMAKE_MAKE_PROGRAM} -f /usr/share/selinux/devel/Makefile ${OTC_SELINUX_PP_NAME}
      COMMAND ${BZIP2_PROGRAM} -9 -f ${OTC_SELINUX_PP_NAME}
      VERBATIM
    )
  endif()

  build_cpack_config()
endmacro()

# Build CPackConfig & targets for deb
macro(build_otc_selinux_deb_cpack_config)
  build_otc_selinux_cpack_config()
  reset_cpack_state()
endmacro()

# Build CPackConfig & targets for productbuild
macro(build_otc_selinux_productbuild_cpack_config)
  require_variables(
    "supported_archs"
  )

  # required for our CPack.distribution.dist.in template
  set(CPACK_PRODUCTBUILD_HOST_ARCHITECTURES "${supported_archs}")

  build_otc_selinux_cpack_config()
  reset_cpack_state()
endmacro()

# Build CPackConfig & targets for rpm
macro(build_otc_selinux_rpm_cpack_config)
  build_otc_selinux_cpack_config()
  reset_cpack_state()
endmacro()
