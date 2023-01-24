require_variables(
  "HOOK_TEMPLATES_DIR"
  "HOOK_TEMPLATES_OUTPUT_DIR"
)

set(DEB_HOOK_TEMPLATES_DIR "${HOOK_TEMPLATES_DIR}/deb")
set(DEB_HOOK_TEMPLATES_OUTPUT_DIR "${HOOK_TEMPLATES_OUTPUT_DIR}/deb")

function(render_deb_hook_templates)
  require_variables(
    "COMMON_HOOK_TEMPLATES_OUTPUT_DIR"
    "SERVICE_USER"
    "SERVICE_GROUP"
    "SERVICE_USER_HOME"
  )

  set(file_names
    "postinst"
    "postrm"
    "preinst"
    "prerm"
  )

  file(READ "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/linux-functions" common_linux_functions)
  file(READ "${COMMON_HOOK_TEMPLATES_OUTPUT_DIR}/otc-linux-functions" otc_linux_functions)

  foreach(file_name ${file_names})
    set(input_path "${DEB_HOOK_TEMPLATES_DIR}/${file_name}.in")
    set(output_path "${DEB_HOOK_TEMPLATES_OUTPUT_DIR}/${file_name}")
    render_template("${input_path}" "${output_path}")
  endforeach()
endfunction()
