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
	hostmetricsConfigPath = confDAvailablePath + "/hostmetrics.yaml"
	cacheDirectory        = "/var/cache/otelcol-sumo/"
	logDirPath            = "/var/log/otelcol-sumo"
	sumoRemotePath        = "/etc/otelcol-sumo/sumologic-remote.yaml"

	installToken        = "token"
	installTokenEnv     = "SUMOLOGIC_INSTALLATION_TOKEN"
	apiBaseURL          = "https://open-collectors.sumologic.com"
	ephemeralConfigPath = confDAvailablePath + "/ephemeral.yaml"

	curlTimeoutErrorCode = 28
)
