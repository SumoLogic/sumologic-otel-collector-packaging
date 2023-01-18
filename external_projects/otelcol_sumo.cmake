# Global property containing lists of otelcol-sumo external project targets
# which are used to create a target to download all of the otelcol-sumo binaries
# for each platform
set_property(GLOBAL PROPERTY all_otelcol_sumo_external_project_targets)

function(create_otelcol_sumos_target)
  get_property(target_dependencies GLOBAL PROPERTY all_otelcol_sumo_external_project_targets)
  add_custom_target("otelcol-sumos" DEPENDS ${target_dependencies})
endfunction()

# An external project to download the otelcol-sumo binary
function(create_otelcol_sumo_target goos goarch fips)
  require_variables(
    "OTC_VERSION"
    "OTC_SUMO_VERSION"
    "OTC_TAG"
  )

  set(project_name "otelcol-sumo")
  set(file_name "otelcol-sumo-${OTC_VERSION}-sumo-${OTC_SUMO_VERSION}")

  if(fips)
    set(project_name "${project_name}-fips")
    set(file_name "${file_name}-fips")
  endif()

  set(project_name "${project_name}-${goos}-${goarch}")
  set(file_name "${file_name}-${goos}_${goarch}")
  set(file_url "${OTC_BASE_URL}/releases/download/${OTC_TAG}/${file_name}")
  set(download_dir "${CMAKE_BINARY_DIR}/external_projects/${project_name}")
  set(download_name "otelcol-sumo")

  set(OTELCOL_SUMO_DOWNLOAD_DIR "${download_dir}" PARENT_SCOPE)

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
