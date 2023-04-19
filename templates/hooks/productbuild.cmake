require_variables(
  "HOOK_TEMPLATES_DIR"
  "HOOK_TEMPLATES_OUTPUT_DIR"
)

set(PRODUCTBUILD_HOOK_TEMPLATES_DIR "${HOOK_TEMPLATES_DIR}/productbuild")
set(PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR "${HOOK_TEMPLATES_OUTPUT_DIR}/productbuild")

function(render_productbuild_hook_templates)
  require_variables(
    "COMMON_HOOK_TEMPLATES_OUTPUT_DIR"
    "OTC_LAUNCHD_DIR"
    "SERVICE_USER"
    "SERVICE_GROUP"
    "SERVICE_USER_HOME"
  )

  set(file_names
    "postflight"
    "preflight"
  )

  file(READ "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/darwin-functions" common_darwin_functions)
  file(READ "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/otc-darwin-functions" otc_darwin_functions)

  foreach(file_name ${file_names})
    set(input_path "${PRODUCTBUILD_HOOK_TEMPLATES_DIR}/${file_name}.in")
    set(output_path "${PRODUCTBUILD_HOOK_TEMPLATES_OUTPUT_DIR}/${file_name}")
    render_template("${input_path}" "${output_path}")
  endforeach()
endfunction()
