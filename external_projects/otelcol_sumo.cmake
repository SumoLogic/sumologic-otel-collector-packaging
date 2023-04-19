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
endfunction()
