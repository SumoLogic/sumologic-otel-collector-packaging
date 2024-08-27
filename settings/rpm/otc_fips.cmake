macro(set_otc_fips_rpm_settings)
  set_otc_rpm_settings()

  set(CPACK_RPM_PACKAGE_CONFLICTS "otelcol-sumo")
endmacro()
