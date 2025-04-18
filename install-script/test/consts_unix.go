//go:build linux || darwin

package sumologic_scripts_tests

const (
	binaryPath            = "/usr/local/bin/otelcol-sumo"
	libPath               = "/var/lib/otelcol-sumo"
	fileStoragePath       = libPath + "/file_storage"
	etcPath               = "/etc/otelcol-sumo"
	scriptPath            = "../install.sh"
	configPath            = etcPath + "/sumologic.yaml"
	confDPath             = etcPath + "/conf.d"
	confDAvailablePath    = etcPath + "/conf.d-available"
	opampDPath            = etcPath + "/opamp.d"
	userConfigPath        = confDPath + "/00-otelcol-config-settings.yaml"
	hostmetricsConfigPath = confDPath + "/hostmetrics.yaml"
	cacheDirectory        = "/var/cache/otelcol-sumo/"
	logDirPath            = "/var/log/otelcol-sumo"
	sumoRemotePath        = "/etc/otelcol-sumo/sumologic-remote.yaml"

	installToken        = "token"
	installTokenEnv     = "SUMOLOGIC_INSTALLATION_TOKEN"
	apiBaseURL          = "https://open-collectors.sumologic.com"
	ephemeralConfigPath = confDPath + "/ephemeral.yaml"

	curlTimeoutErrorCode = 28

	configPathDirPermissions  uint32 = 0770
	configPathFilePermissions uint32 = 0660
	confDPathFilePermissions  uint32 = 0660
	etcPathPermissions        uint32 = 0771
	opampDPermissions         uint32 = 0770
)
