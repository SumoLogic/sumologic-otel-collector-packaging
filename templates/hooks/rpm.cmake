require_variables(
  "HOOK_TEMPLATES_DIR"
  "HOOK_TEMPLATES_OUTPUT_DIR"
)

set(RPM_HOOK_TEMPLATES_DIR "${HOOK_TEMPLATES_DIR}/rpm")
set(RPM_HOOK_TEMPLATES_OUTPUT_DIR "${HOOK_TEMPLATES_OUTPUT_DIR}/rpm")

function(render_rpm_hook_templates)
  require_variables(
    "COMMON_HOOK_TEMPLATES_OUTPUT_DIR"
    "SERVICE_USER"
    "SERVICE_GROUP"
    "SERVICE_USER_HOME"
  )

  set(file_names
    "after-install"
    "after-remove"
    "before-install"
    "before-remove"
  )

  file(READ "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/linux-functions" common_linux_functions)
  file(READ "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/otc-linux-functions" otc_linux_functions)

  foreach(file_name ${file_names})
    set(input_path "${RPM_HOOK_TEMPLATES_DIR}/${file_name}.in")
    set(output_path "${RPM_HOOK_TEMPLATES_OUTPUT_DIR}/${file_name}")
    render_template("${input_path}" "${output_path}")
  endforeach()
endfunction()
