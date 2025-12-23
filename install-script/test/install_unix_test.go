//go:build !(windows || darwin)

package sumologic_scripts_tests

import (
	"testing"
)

func TestInstallScript(t *testing.T) {
	notInstalledChecks := []checkFunc{
		checkBinaryNotCreated,
		checkConfigNotCreated,
		checkUserConfigNotCreated,
	}

	for _, spec := range []testSpec{
		{
			name:        "no arguments",
			options:     installOptions{},
			preChecks:   notInstalledChecks,
			postChecks:  notInstalledChecks,
			installCode: 1,
		},
		{
			name: "skip installation token",
			options: installOptions{
				skipInstallToken: true,
			},
			preChecks:   notInstalledChecks,
			postChecks:  notInstalledChecks,
			installCode: 1,
		},
		{
			name: "installation token only",
			options: installOptions{
				installToken: installToken,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkEphemeralConfigFileNotCreated(ephemeralConfigPath),
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileCreated,
			},
		},
		{
			name: "installation token and ephemeral",
			options: installOptions{
				installToken: installToken,
				ephemeral:    true,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkEphemeralConfigFileCreated(ephemeralConfigPath),
				checkEphemeralNotEnabledInRemote(sumoRemotePath),
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileCreated,
			},
		},
		{
			name: "installation token and hostmetrics",
			options: installOptions{
				installToken:       installToken,
				installHostmetrics: true,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkHostmetricsConfigCreated,
				checkHostmetricsOwnershipAndPermissions(systemUser, systemGroup),
			},
		},
		{
			name: "installation token and remotely-managed",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkEphemeralConfigFileNotCreated(ephemeralConfigPath),
				checkEphemeralNotEnabledInRemote(sumoRemotePath),
			},
		},
		{
			name: "installation token, remotely-managed, and ephemeral",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				ephemeral:       true,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkEphemeralConfigFileNotCreated(ephemeralConfigPath),
				checkEphemeralEnabledInRemote(sumoRemotePath),
			},
		},
		{
			name: "installation token, remotely-managed, and opamp-api",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				opampEndpoint:   "wss://example.com",
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkEphemeralConfigFileNotCreated(ephemeralConfigPath),
				checkEphemeralNotEnabledInRemote(sumoRemotePath),
				checkOpAmpEndpointSet,
			},
		},
		{
			name: "installation token, remotely-managed and timezone",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				timezone:        "Europe/Prague",
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkTimezoneConfigInRemote(sumoRemotePath),
				checkEphemeralConfigFileNotCreated(ephemeralConfigPath),
				checkEphemeralNotEnabledInRemote(sumoRemotePath),
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileCreated,
			},
		},
		{
			name: "configuration with tags",
			options: installOptions{
				installToken: installToken,
				tags: map[string]string{
					"lorem":     "ipsum",
					"foo":       "bar",
					"escape_me": "'\\/",
					"slash":     "a/b",
					"numeric":   "1_024",
				},
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkTags,
			},
		},
		{
			name: "installed from package path",
			options: installOptions{
				installToken: installToken,
				packagePath:  getPackagePath(t),
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
			},
		},
		{
			name: "locally-managed and timezone",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: false,
				timezone:        "Europe/Prague",
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkTimezoneInConfig,
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileCreated,
			},
		},
		{
			name: "installation token, locally-managed, and clobber",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: false,
				clobber:         true,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileCreated,
				checkClobberInConfig,
			},
		},
		{
			name: "installation token, remotely-managed and clobber",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				clobber:         true,
			},
			preChecks: notInstalledChecks,
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkClobberEnabledInRemote(sumoRemotePath),
				checkEphemeralConfigFileNotCreated(ephemeralConfigPath),
				checkEphemeralNotEnabledInRemote(sumoRemotePath),
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileCreated,
			},
		},
	} {
		t.Run(spec.name, func(t *testing.T) {
			if err := runTest(t, &spec); err != nil {
				t.Error(err)
			}
		})
	}
}

func getPackagePath(t testing.TB) string {
	t.Helper()
	path := os.Getenv("OTELCOL_SUMO_PACKAGE_PATH")
	if path == "" {
		t.Fatal("missing environment variable: OTELCOL_SUMO_PACKAGE_PATH")
	}
	return path
}
