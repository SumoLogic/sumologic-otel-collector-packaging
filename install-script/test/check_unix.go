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
)

func checkAbortedDueToNoToken(c check) bool {
	if !assert.Greater(c.test, len(c.output), 1) {
		return false
	}
	return assert.Contains(c.test, c.output, "Installation token has not been provided. Please set the 'SUMOLOGIC_INSTALLATION_TOKEN' environment variable.")
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
