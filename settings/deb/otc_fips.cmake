macro(set_otc_fips_deb_settings)
  set_otc_deb_settings()

  set(CPACK_DEBIAN_PACKAGE_CONFLICTS "otelcol-sumo")
endmacro()
