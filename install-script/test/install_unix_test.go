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
	} {
		t.Run(spec.name, func(t *testing.T) {
			if err := runTest(t, &spec); err != nil {
				t.Error(err)
			}
		})
	}
}
