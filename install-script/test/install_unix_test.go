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
			preChecks:   []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkAbortedDueToNoToken, checkUserNotExists},
			installCode: 1,
		},
		{
			name: "download only",
			options: installOptions{
				downloadOnly: true,
			},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
		},
		{
			name: "download only with timeout",
			options: installOptions{
				downloadOnly:      true,
				timeout:           1,
				dontKeepDownloads: true,
			},
			// Skip this test as getting binary in github actions takes less than one second
			conditionalChecks: []condCheckFunc{checkSkipTest},
			preChecks:         []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists,
				checkDownloadTimeout},
			installCode: curlTimeoutErrorCode,
		},
		{
			name: "skip config",
			options: installOptions{
				skipConfig:       true,
				skipInstallToken: true,
			},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigNotCreated, checkUserConfigNotCreated},
		},
		{
			name: "skip installation token",
			options: installOptions{
				skipInstallToken: true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkUserConfigNotCreated,
			},
		},
		{
			name: "override default config",
			options: installOptions{
				skipInstallToken: true,
				autoconfirm:      true,
			},
			preActions: []checkFunc{preActionMockConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkConfigOverrided, checkUserConfigNotCreated},
		},
		{
			name: "installation token only",
			options: installOptions{
				installToken: installToken,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkLatestAppVersion,
				checkConfigCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkUserConfigCreated,
				checkEphemeralNotInConfig(userConfigPath),
				checkTokenInConfig,

				checkUserNotExists,
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
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkUserConfigCreated,
				checkTokenInConfig,
				checkEphemeralInConfig(userConfigPath),

				checkUserNotExists,
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
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryNotCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkUserConfigCreated,
				checkTokenInConfig,

				checkUserNotExists,
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
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkTokenInSumoConfig,
				checkEphemeralNotInConfig(configPath),

				checkUserNotExists,
			},
		},
		{
			name: "installation token, remotely-managed, and ephemeral",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				ephemeral:       true,
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkTokenInSumoConfig,
				checkEphemeralInConfig(configPath),

				checkUserNotExists,
			},
		},
		{
			name: "installation token, remotely-managed, and opamp-api",
			options: installOptions{
				installToken:    installToken,
				remotelyManaged: true,
				opampEndpoint:   "wss://example.com",
			},
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkRemoteConfigDirectoryCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkTokenInSumoConfig,
				checkEphemeralNotInConfig(configPath),

				checkUserNotExists,
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
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkUserConfigCreated,
				checkTokenInConfig,

				checkUserNotExists,
			},
		},
		{
			name: "same installation token",
			options: installOptions{
				installToken: installToken,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteTokenToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkUserConfigCreated, checkTokenInConfig},
		},
		{
			name: "different installation token",
			options: installOptions{
				installToken: installToken,
			},
			preActions:  []checkFunc{preActionMockUserConfig, preActionWriteDifferentTokenToUserConfig},
			preChecks:   []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkAbortedDueToDifferentToken},
			installCode: 1,
		},
		{
			name: "adding installation token",
			options: installOptions{
				installToken: installToken,
			},
			preActions: []checkFunc{preActionMockUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkTokenInConfig},
		},
		{
			name: "editing installation token",
			options: installOptions{
				apiBaseURL:   apiBaseURL,
				installToken: installToken,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteEmptyUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkTokenInConfig},
		},
		{
			name: "same api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteAPIBaseURLToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkUserConfigCreated, checkAPIBaseURLInConfig},
		},
		{
			name: "different api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteDifferentAPIBaseURLToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated,
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
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkAPIBaseURLInConfig},
		},
		{
			name: "editing api base url",
			options: installOptions{
				apiBaseURL:       apiBaseURL,
				skipInstallToken: true,
			},
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteEmptyUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkAPIBaseURLInConfig},
		},
		{
			name:       "empty installation token",
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteDifferentTokenToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkDifferentTokenInConfig},
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
			preChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated, checkUserNotExists},
			postChecks: []checkFunc{
				checkBinaryCreated,
				checkBinaryIsRunning,
				checkConfigCreated,
				checkConfigFilesOwnershipAndPermissions(rootUser, rootGroup),
				checkTags,
			},
		},
		{
			name: "same tags",
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
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteTagsToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkUserConfigCreated, checkTags},
		},
		{
			name: "different tags",
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
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteDifferentTagsToUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkDifferentTags,
				checkAbortedDueToDifferentTags},
			installCode: 1,
		},
		{
			name: "editing tags",
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
			preActions: []checkFunc{preActionMockUserConfig, preActionWriteEmptyUserConfig},
			preChecks:  []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryCreated, checkBinaryIsRunning, checkConfigCreated, checkTags},
		},
		{
			name: "uninstallation without autoconfirm fails",
			options: installOptions{
				uninstall: true,
			},
			installCode: 1,
			preActions:  []checkFunc{preActionMockStructure},
			preChecks:   []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks:  []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated},
		},
		{
			name: "uninstallation with autoconfirm",
			options: installOptions{
				autoconfirm: true,
				uninstall:   true,
			},
			preActions: []checkFunc{preActionMockStructure},
			preChecks:  []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryNotCreated, checkConfigCreated, checkUserConfigCreated, checkUninstallationOutput},
		},
		{
			name: "purge",
			options: installOptions{
				uninstall:   true,
				purge:       true,
				autoconfirm: true,
			},
			preActions: []checkFunc{preActionMockStructure},
			preChecks:  []checkFunc{checkBinaryCreated, checkConfigCreated, checkUserConfigCreated, checkUserNotExists},
			postChecks: []checkFunc{checkBinaryNotCreated, checkConfigNotCreated, checkUserConfigNotCreated},
		},
	} {
		t.Run(spec.name, func(t *testing.T) {
			runTest(t, &spec)
		})
	}
}
