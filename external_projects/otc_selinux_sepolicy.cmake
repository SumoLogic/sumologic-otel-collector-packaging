# An external project to build & compress the sepolicy pp file for otelcol-sumo
function(create_build_otelcol_sumo_sepolicy_target)
  require_variables(
    "OTC_VERSION"
    "OTC_SUMO_VERSION"
  )

  set(project_name "otelcol-sumo-selinux-policy")
  set(source_dir "${CMAKE_BINARY_DIR}/external_projects/${project_name}")

  set(OTELCOL_SUMO_SEPOLICY_DIR "${source_dir}" PARENT_SCOPE)

  ExternalProject_Add("${project_name}"
    URL "${file_url}"
    DOWNLOAD_DIR "${download_dir}"
    DOWNLOAD_NAME "${download_name}"
    DOWNLOAD_NO_EXTRACT true
    # We only care about downloading; disable all other commands
    CONFIGURE_COMMAND ""
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    TEST_COMMAND ""
  )

  append_global_property(all_otelcol_sumo_external_project_targets "${project_name}")
endfunction()
