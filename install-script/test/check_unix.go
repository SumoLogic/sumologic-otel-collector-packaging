//go:build linux || darwin

package sumologic_scripts_tests

import (
	"io/fs"
	"os"
	"os/user"
	"strconv"
	"syscall"
	"testing"

	"github.com/stretchr/testify/assert"
	"gopkg.in/yaml.v3"
)

type configRoot struct {
	Extensions *configExtensions `yaml:"extensions,omitempty"`
}

type configExtensions struct {
	Sumologic *sumologicExt `yaml:"sumologic,omitempty"`
}

type sumologicExt struct {
	Ephemeral bool `yaml:"ephemeral,omitempty"`
}

func checkAbortedDueToNoToken(c check) bool {
	if !assert.Greater(c.test, len(c.output), 1) {
		return false
	}
	return assert.Contains(c.test, c.output, "Installation token has not been provided. Please set the 'SUMOLOGIC_INSTALLATION_TOKEN' environment variable.")
}

func checkEphemeralConfigFileCreated(p string) func(c check) bool {
	return func(c check) bool {
		return assert.FileExists(c.test, p, "ephemeral config file has not been created")
	}
}

func checkEphemeralConfigFileNotCreated(p string) func(c check) bool {
	return func(c check) bool {
		return assert.NoFileExists(c.test, p, "ephemeral config file has been created")
	}
}

func checkEphemeralEnabledInRemote(p string) func(c check) bool {
	return func(c check) bool {
		yamlFile, err := os.ReadFile(p)
		if assert.NoError(c.test, err, "sumologic remote config file could not be read") {
			return false
		}

		var config configRoot

		if assert.NoError(c.test, yaml.Unmarshal(yamlFile, &config), "could not parse yaml") {
			return false
		}

		return config.Extensions.Sumologic.Ephemeral
	}
}

func checkEphemeralNotEnabledInRemote(p string) func(c check) bool {
	return func(c check) bool {
		yamlFile, err := os.ReadFile(p)
		if err != nil {
			// assume the error is due to the file not existing, which is valid
			return true
		}

		var config configRoot

		if assert.NoError(c.test, yaml.Unmarshal(yamlFile, &config), "could not parse yaml") {
			return false
		}

		return !config.Extensions.Sumologic.Ephemeral
	}
}

func preActionMockConfig(c check) bool {
	err := os.MkdirAll(etcPath, fs.FileMode(etcPathPermissions))
	if !assert.NoError(c.test, err) {
		return false
	}

	f, err := os.Create(configPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	err = f.Chmod(fs.FileMode(configPathFilePermissions))
	return assert.NoError(c.test, err)
}

func preActionMockUserConfig(c check) bool {
	err := os.MkdirAll(etcPath, fs.FileMode(etcPathPermissions))
	if !assert.NoError(c.test, err) {
		return false
	}

	err = os.MkdirAll(confDPath, fs.FileMode(configPathDirPermissions))
	if !assert.NoError(c.test, err) {
		return false
	}

	f, err := os.Create(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	err = f.Chmod(fs.FileMode(confDPathFilePermissions))
	return assert.NoError(c.test, err)
}

func PathHasOwner(t *testing.T, path string, ownerName string, groupName string) bool {
	info, err := os.Stat(path)
	if !assert.NoError(t, err) {
		return false
	}

	// get the owning user and group
	stat := info.Sys().(*syscall.Stat_t)
	uid := strconv.FormatUint(uint64(stat.Uid), 10)
	gid := strconv.FormatUint(uint64(stat.Gid), 10)

	usr, err := user.LookupId(uid)
	if !assert.NoError(t, err) {
		return false
	}

	group, err := user.LookupGroupId(gid)
	if !assert.NoError(t, err) {
		return false
	}

	if !assert.Equal(t, ownerName, usr.Username, "%s should be owned by user '%s'", path, ownerName) {
		return false
	}
	return assert.Equal(t, groupName, group.Name, "%s should be owned by group '%s'", path, groupName)
}
