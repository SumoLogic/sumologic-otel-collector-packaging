require_variables(
  "HOOK_TEMPLATES_DIR"
  "HOOK_TEMPLATES_OUTPUT_DIR"
)

set(COMMON_HOOK_TEMPLATES_DIR "${HOOK_TEMPLATES_DIR}/common")
set(COMMON_HOOK_TEMPLATES_OUTPUT_DIR "${HOOK_TEMPLATES_OUTPUT_DIR}/common")

function(render_common_hook_templates)
  require_variables(
    "SERVICE_USER"
    "SERVICE_GROUP"
    "SERVICE_USER_HOME"
    "OTC_CONFIG_DIR"
    "OTC_CONFIG_PATH"
    "OTC_USER_ENV_DIR"
    "OTC_CONFIG_FRAGMENT_DIR"
    "OTC_BIN_PATH"
  )

  set(file_names
    "darwin-functions"
    "linux-functions"
    "otc-darwin-functions"
    "otc-linux-functions"
  )

  foreach(file_name ${file_names})
    set(input_path "${COMMON_HOOK_TEMPLATES_DIR}/${file_name}.in")
    set(output_path "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/${file_name}")
    render_template("${input_path}" "${output_path}")
  endforeach()
endfunction()
