//go:build !(windows || darwin)

package sumologic_scripts_tests

import (
	"testing"
)

func TestInstallScript(t *testing.T) {
	for _, spec := range []testSpec{
		{
			name:        "no arguments",
			options:     installOptions{},
			preChecks:   []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			installCode: 1,
		},
		{
			name: "skip installation token",
			options: installOptions{
				skipInstallToken: true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
			},
		},
		{
			name: "override default config",
			options: installOptions{
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkConfigOverrided},
		},
		{
			name: "installation token only",
			options: installOptions{
				installToken: installToken,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkEphemeralNotInConfig(userConfigPath),
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileNotCreated,
			},
		},
		{
			name: "installation token and ephemeral",
			options: installOptions{
				installToken: installToken,
				ephemeral:    true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkEphemeralInConfig(ephemeralConfigPath),
				checkHostmetricsConfigNotCreated,
				checkTokenEnvFileNotCreated,
			},
		},
		{
			name: "installation token and hostmetrics",
			options: installOptions{
				installToken:       installToken,
				installHostmetrics: true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryNotCreated,
				checkHostmetricsConfigCreated,
				checkHostmetricsOwnershipAndPermissions(rootUser, rootGroup),
			},
		},
		{
			name: "installation token and remotely-managed",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkEphemeralNotInConfig(configPath),
			},
		},
		{
			name: "installation token, remotely-managed, and ephemeral",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				ephemeral:       true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkEphemeralInConfig(ephemeralConfigPath),
			},
		},
		{
			name: "installation token, remotely-managed, and opamp-api",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				opampEndpoint:   "wss://example.com",
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkEphemeralNotInConfig(configPath),
				checkOpAmpEndpointSet,
			},
		},
		{
			name: "installation token only, binary not in PATH",
			options: installOptions{
				installToken: installToken,
				envs: map[string]string{
					"PATH": "/sbin:/bin:/usr/sbin:/usr/bin",
				},
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
			},
		},
		{
			name: "same installation token",
			options: installOptions{
				installToken: installToken,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteTokenToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated},
		},
		{
			name: "adding installation token",
			options: installOptions{
				installToken: installToken,
			},
			preActions: []checkFunc{preActionMockUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated},
		},
		{
			name: "editing installation token",
			options: installOptions{
				apiBaseURL:   apiBaseURL,
				installToken: installToken,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteEmptyUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated},
		},
		{
			name: "same api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteAPIBaseURLToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkAPIBaseURLInConfig},
		},
		{
			name: "different api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteDifferentAPIBaseURLToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated,
				checkAbortedDueToDifferentAPIBaseURL},
			installCode: 1,
		},
		{
			name: "adding api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkAPIBaseURLInConfig},
		},
		{
			name: "editing api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteEmptyUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkAPIBaseURLInConfig},
		},
		{
			name: "configuration with tags",
			options: installOptions{
				skipInstallToken: true,
				tags: map[string]string{
					"lorem":     "ipsum",
					"foo":       "bar",
					"escape_me": "'\\/",
					"slash":     "a/b",
					"numeric":   "1_024",
				},
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkTags,
			},
		},
	} {
		t.Run(spec.name, func(t *testing.T) {
			runTest(t, &spec)
		})
	}
}
