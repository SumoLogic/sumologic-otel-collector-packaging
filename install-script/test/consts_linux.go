package sumologic_scripts_tests

const (
	envDirectoryPath string = etcPath + "/env"
	tokenEnvFilePath string = envDirectoryPath + "/token.env"

	// TODO: fix mismatch between package permissions & expected permissions
	commonConfigPathFilePermissions uint32 = 0750
	configPathDirPermissions        uint32 = 0770
	configPathFilePermissions       uint32 = 0600
	confDPathFilePermissions        uint32 = 0600
	etcPathPermissions              uint32 = 0551
	opampDPermissions               uint32 = 0770

	rootGroup   string = "root"
	rootUser    string = "root"
	systemGroup string = "otelcol-sumo"
	systemUser  string = "otelcol-sumo"
)
