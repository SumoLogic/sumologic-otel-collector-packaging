package sumologic_scripts_tests

import (
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

type check struct {
	test                *testing.T
	installOptions      installOptions
	code                int
	err                 error
	expectedInstallCode int
	output              []string
	errorOutput         []string
}

type condCheckFunc func(check) bool

func checkSkipTest(c check) bool {
	return false
}

type checkFunc func(check) bool

func checkBinaryCreated(c check) bool {
	return assert.FileExists(c.test, binaryPath, "binary has not been created")
}

func checkBinaryNotCreated(c check) bool {
	return assert.NoFileExists(c.test, binaryPath, "binary is already created")
}

func checkBinaryIsRunning(c check) bool {
	cmd := exec.Command(binaryPath, "--version")
	err := cmd.Start()
	if !assert.NoError(c.test, err, "error while checking version") {
		return false
	}

	code, err := exitCode(cmd)
	assert.NoError(c.test, err, "error while checking exit code")
	assert.Equal(c.test, 0, code, "got error code while checking version")
	return true
}

func checkRun(c check) bool {
	return assert.Equal(c.test, c.expectedInstallCode, c.code, "unexpected installation script error code")
}

func checkConfigCreated(c check) bool {
	return assert.FileExists(c.test, configPath, "configuration has not been created properly")
}

func checkConfigNotCreated(c check) bool {
	return assert.NoFileExists(c.test, configPath, "configuration has been created")
}

func checkConfigOverrided(c check) bool {
	conf, err := getConfig(configPath)
	if err != nil {
		c.test.Error(err)
		return false
	}

	if got, want := conf.Extensions.Sumologic.InstallationToken, "${SUMOLOGIC_INSTALLATION_TOKEN}"; got != want {
		c.test.Errorf("bad installation token: got %q, want %q", got, want)
	}
	return true
}

func checkUserConfigCreated(c check) bool {
	return assert.FileExists(c.test, userConfigPath, "user configuration has not been created properly")
}

func checkUserConfigNotCreated(c check) bool {
	return assert.NoFileExists(c.test, userConfigPath, "user configuration has been created")
}

func checkHomeDirectoryCreated(c check) bool {
	return assert.DirExists(c.test, libPath, "home directory has not been created properly")
}

func checkNoBakFilesPresent(c check) bool {
	cwd, err := os.Getwd()
	if !assert.NoError(c.test, err) {
		return false
	}
	cwdGlob := filepath.Join(cwd, "*.bak")
	etcPathGlob := filepath.Join(etcPath, "*.bak")
	etcPathNestedGlob := filepath.Join(etcPath, "*", "*.bak")

	for _, bakGlob := range []string{cwdGlob, etcPathGlob, etcPathNestedGlob} {
		bakFiles, err := filepath.Glob(bakGlob)
		if !assert.NoError(c.test, err) {
			return false
		}
		if !assert.Empty(c.test, bakFiles) {
			return false
		}
	}
	return true
}

func checkOpAmpEndpointSet(c check) bool {
	conf, err := getConfig(sumoRemotePath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	if !assert.Equal(c.test, conf.Extensions.OpAmp.Endpoint, "wss://example.com") {
		return false
	}
	return true
}

func checkHostmetricsConfigCreated(c check) bool {
	return assert.FileExists(c.test, hostmetricsConfigPath, "hostmetrics configuration has not been created properly")
}

func checkHostmetricsConfigNotCreated(c check) bool {
	return assert.NoFileExists(c.test, hostmetricsConfigPath, "hostmetrics configuration has been created")
}

func checkRemoteConfigDirectoryCreated(c check) bool {
	return assert.DirExists(c.test, opampDPath, "remote configuration directory has not been created properly")
}

func checkRemoteConfigDirectoryNotCreated(c check) bool {
	return assert.NoDirExists(c.test, opampDPath, "remote configuration directory has been created")
}

func checkTags(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	errored := false
	for k, v := range c.installOptions.tags {
		if !assert.Equal(c.test, v, conf.Extensions.Sumologic.Tags[k], "tag is different than expected") {
			errored = true
		}
	}
	return !errored
}

func checkDifferentTags(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, "tag", conf.Extensions.Sumologic.Tags["some"], "tag is different than expected")
}

func checkAbortedDueToDifferentToken(c check) bool {
	if !assert.Greater(c.test, len(c.output), 0) {
		return false
	}
	return assert.Contains(c.test, c.output[len(c.output)-1], "You are trying to install with different token than in your configuration file!")
}

func preActionWriteAPIBaseURLToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.APIBaseURL = c.installOptions.apiBaseURL
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteDifferentAPIBaseURLToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.APIBaseURL = "different" + c.installOptions.apiBaseURL
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteDifferentTagsToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.Tags = map[string]string{
		"some": "tag",
	}
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteEmptyUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteTagsToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.Tags = c.installOptions.tags
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func checkAbortedDueToDifferentAPIBaseURL(c check) bool {
	if !assert.Greater(c.test, len(c.output), 0) {
		return false
	}
	return assert.Contains(c.test, c.output[len(c.output)-1], "You are trying to install with different api base url than in your configuration file!")
}

func checkAPIBaseURLInConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, c.installOptions.apiBaseURL, conf.Extensions.Sumologic.APIBaseURL, "api base url is different than expected")
}

func checkTimezoneInConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, c.installOptions.timezone, conf.Extensions.Sumologic.Timezone, "timezone is different than expected")
}

func PathHasPermissions(t *testing.T, path string, perms uint32) bool {
	info, err := os.Stat(path)
	if !assert.NoError(t, err) {
		return false
	}
	expected := fs.FileMode(perms)
	got := info.Mode().Perm()
	return assert.Equal(t, expected, got, "%s should have %o permissions but has %o", path, expected, got)
}

func PathHasUserACL(t *testing.T, path string, ownerName string, perms string) bool {
	cmd := exec.Command("/usr/bin/getfacl", path)

	output, err := cmd.Output()
	if !assert.NoError(t, err, "error while checking "+path+" acl") {
		return false
	}
	return assert.Contains(t, string(output), "user:"+ownerName+":"+perms)
}
