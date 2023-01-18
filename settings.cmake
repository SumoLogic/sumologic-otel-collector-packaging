# Include common package settings
include("${SETTINGS_DIR}/common.cmake")
include("${SETTINGS_DIR}/deb/common.cmake")
include("${SETTINGS_DIR}/rpm/common.cmake")

# Include OTC package settings
include("${SETTINGS_DIR}/otc.cmake")
include("${SETTINGS_DIR}/deb/otc.cmake")
include("${SETTINGS_DIR}/rpm/otc.cmake")
