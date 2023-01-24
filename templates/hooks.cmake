require_variables(
  "TEMPLATES_DIR"
  "TEMPLATES_OUTPUT_DIR"
)

set(HOOK_TEMPLATES_DIR "${TEMPLATES_DIR}/hooks")
set(HOOK_TEMPLATES_OUTPUT_DIR "${TEMPLATES_OUTPUT_DIR}/hooks")

include("${HOOK_TEMPLATES_DIR}/common.cmake")
include("${HOOK_TEMPLATES_DIR}/deb.cmake")
include("${HOOK_TEMPLATES_DIR}/rpm.cmake")
