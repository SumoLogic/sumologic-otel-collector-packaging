# Include common package settings
include("${SETTINGS_DIR}/common.cmake")
include("${SETTINGS_DIR}/deb/common.cmake")
include("${SETTINGS_DIR}/productbuild/common.cmake")
include("${SETTINGS_DIR}/rpm/common.cmake")

# Include otc package settings
include("${SETTINGS_DIR}/otc.cmake")
include("${SETTINGS_DIR}/deb/otc.cmake")
include("${SETTINGS_DIR}/productbuild/otc.cmake")
include("${SETTINGS_DIR}/rpm/otc.cmake")

# Include otc_selinux package settings
include("${SETTINGS_DIR}/otc_selinux.cmake")
include("${SETTINGS_DIR}/deb/otc_selinux.cmake")
include("${SETTINGS_DIR}/rpm/otc_selinux.cmake")
