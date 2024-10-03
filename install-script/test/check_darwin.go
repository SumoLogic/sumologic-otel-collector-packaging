package sumologic_scripts_tests

import (
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/stretchr/testify/assert"
)

func checkConfigFilesOwnershipAndPermissions(ownerName string, ownerGroup string) func(c check) bool {
	return func(c check) bool {
		PathHasPermissions(c.test, etcPath, etcPathPermissions)
		PathHasOwner(c.test, etcPath, ownerName, ownerGroup)

		etcPathGlob := filepath.Join(etcPath, "*")
		etcPathNestedGlob := filepath.Join(etcPath, "*", "*")

		for _, glob := range []string{etcPathGlob, etcPathNestedGlob} {
			paths, err := filepath.Glob(glob)
			if !assert.NoError(c.test, err) {
				return false
			}
			for _, path := range paths {
				var permissions uint32
				info, err := os.Stat(path)
				if !assert.NoError(c.test, err) {
					return false
				}
				if info.IsDir() {
					switch path {
					case etcPath:
						permissions = etcPathPermissions
					case opampDPath:
						// /etc/otelcol-sumo/opamp.d
						permissions = opampDPermissions
					default:
						permissions = configPathDirPermissions
					}
				} else {
					switch path {
					case configPath:
						// /etc/otelcol-sumo/sumologic.yaml
						permissions = configPathFilePermissions
					default:
						// /etc/otelcol-sumo/conf.d/*
						permissions = confDPathFilePermissions
					}
				}
				PathHasPermissions(c.test, path, permissions)
				PathHasOwner(c.test, configPath, ownerName, ownerGroup)
			}
		}
		PathHasPermissions(c.test, configPath, configPathFilePermissions)

		return true
	}
}

func checkDifferentTokenInLaunchdConfig(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.installToken, "installation token has not been provided") {
		return false
	}

	conf, err := getLaunchdConfig(launchdPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	return assert.Equal(c.test, "different"+c.installOptions.installToken, conf.EnvironmentVariables.InstallationToken, "installation token is different than expected")
}

func checkGroupExists(c check) bool {
	exists, err := dsclKeyExistsForPath(c.test, "/Groups", systemGroup)
	assert.NoError(c.test, err)
	return assert.True(c.test, exists, "group has not been created")
}

func checkGroupNotExists(c check) bool {
	exists, err := dsclKeyExistsForPath(c.test, "/Groups", systemGroup)
	assert.NoError(c.test, err)
	return assert.False(c.test, exists, "group has been created")
}

func checkHostmetricsOwnershipAndPermissions(ownerName string, ownerGroup string) func(c check) bool {
	return func(c check) bool {
		PathHasOwner(c.test, hostmetricsConfigPath, ownerName, ownerGroup)
		PathHasPermissions(c.test, hostmetricsConfigPath, confDPathFilePermissions)
		return true
	}
}

func checkLaunchdConfigCreated(c check) bool {
	return assert.FileExists(c.test, launchdPath, "launchd configuration has not been created properly")
}

func checkLaunchdConfigNotCreated(c check) bool {
	return assert.NoFileExists(c.test, launchdPath, "launchd configuration has been created")
}

func checkPackageCreated(c check) bool {
	re, err := regexp.Compile("Package downloaded to: .*/otelcol-sumo.pkg")
	if !assert.NoError(c.test, err) {
		return false
	}

	matchedLine := ""
	for _, line := range c.output {
		if re.MatchString(line) {
			matchedLine = line
		}
	}
	if !assert.NotEmpty(c.test, matchedLine, "package path not in output") {
		return false
	}

	packagePath := strings.TrimPrefix(matchedLine, "Package downloaded to: ")
	return assert.FileExists(c.test, packagePath, "package has not been created")
}

func checkTokenInLaunchdConfig(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.installToken, "installation token has not been provided") {
		return false
	}

	conf, err := getLaunchdConfig(launchdPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	return assert.Equal(c.test, c.installOptions.installToken, conf.EnvironmentVariables.InstallationToken, "installation token is different than expected")
}

func checkEphemeralInConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.True(c.test, c.installOptions.ephemeral, "ephemeral was not specified")

		conf, err := getConfig(p)
		if !assert.NoError(c.test, err, "error while reading configuration") {
			return false
		}

		assert.True(c.test, conf.Extensions.Sumologic.Ephemeral, "ephemeral is not true")
		return true
	}
}

func checkEphemeralNotInConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.False(c.test, c.installOptions.ephemeral, "ephemeral was specified")

		conf, err := getConfig(p)
		if !assert.NoError(c.test, err, "error while reading configuration") {
			return false
		}

		assert.False(c.test, conf.Extensions.Sumologic.Ephemeral, "ephemeral is true")

		return true
	}
}

func checkUserExists(c check) bool {
	exists, err := dsclKeyExistsForPath(c.test, "/Users", systemUser)
	assert.NoError(c.test, err)
	return assert.True(c.test, exists, "user has not been created")
}

func checkUserNotExists(c check) bool {
	exists, err := dsclKeyExistsForPath(c.test, "/Users", systemUser)
	assert.NoError(c.test, err)
	return assert.False(c.test, exists, "user has been created")
}

func preActionInstallPackage(c check) bool {
	c.code, c.output, c.errorOutput, c.err = runScript(c)
	return assert.NoError(c.test, c.err)
}

func preActionInstallPackageWithDifferentAPIBaseURL(c check) bool {
	c.installOptions.apiBaseURL = path.Join(c.installOptions.apiBaseURL, "different")
	c.code, c.output, c.errorOutput, c.err = runScript(c)
	return assert.NoError(c.test, c.err)
}

func preActionInstallPackageWithDifferentTags(c check) bool {
	c.installOptions.tags = map[string]string{
		"some": "tag",
	}
	c.code, c.output, c.errorOutput, c.err = runScript(c)
	return assert.NoError(c.test, c.err)
}

func preActionInstallPackageWithNoAPIBaseURL(c check) bool {
	c.installOptions.apiBaseURL = ""
	c.code, c.output, c.errorOutput, c.err = runScript(c)
	return assert.NoError(c.test, c.err)
}

func preActionInstallPackageWithNoTags(c check) bool {
	c.installOptions.tags = nil
	c.code, c.output, c.errorOutput, c.err = runScript(c)
	return assert.NoError(c.test, c.err)
}

func preActionMockLaunchdConfig(c check) bool {
	f, err := os.Create(launchdPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	err = f.Chmod(fs.FileMode(launchdPathFilePermissions))
	if !assert.NoError(c.test, err) {
		return false
	}

	conf := NewLaunchdConfig()
	err = saveLaunchdConfig(launchdPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteDifferentTokenToLaunchdConfig(c check) bool {
	conf, err := getLaunchdConfig(launchdPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.EnvironmentVariables.InstallationToken = "different" + c.installOptions.installToken
	err = saveLaunchdConfig(launchdPath, conf)
	return assert.NoError(c.test, err)
}
