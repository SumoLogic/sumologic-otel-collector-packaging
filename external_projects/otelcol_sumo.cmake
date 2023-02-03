# Global property containing lists of otelcol-sumo external project targets
# which are used to create a target to download all of the otelcol-sumo binaries
# for each platform
set_property(GLOBAL PROPERTY all_otelcol_sumo_external_project_targets)

function(create_otelcol_sumos_target)
  get_property(target_dependencies GLOBAL PROPERTY all_otelcol_sumo_external_project_targets)
  add_custom_target("otelcol-sumos" DEPENDS ${target_dependencies})
endfunction()

# An external project to download a remote artifact from a GitHub Release.
#   src:  name of the remote artifact
#   dest: destination file name which src will be renamed to
#   tag:  name of tag for the GitHub Release used to download artifacts from
function(create_otelcol_sumo_target src dest tag download_dir)
  set(base_url "https://github.com/SumoLogic/sumologic-otel-collector")
  set(file_url "${base_url}/releases/download/${tag}/${src}")

  ExternalProject_Add("${src}"
    URL "${file_url}"
    DOWNLOAD_DIR "${download_dir}"
    DOWNLOAD_NAME "${dest}"
    DOWNLOAD_NO_EXTRACT true
    # We only care about downloading; disable all other commands
    CONFIGURE_COMMAND ""
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
    TEST_COMMAND ""
  )

  message(STATUS "The ${src} artifact will be fetched from:")
  message(STATUS "\t${file_url}")

  append_global_property(all_otelcol_sumo_external_project_targets "${src}")
endfunction()
