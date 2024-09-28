package sumologic_scripts_tests

import (
	"fmt"
	"io/fs"
	"os"
	"os/exec"
	"os/user"
	"strconv"
	"strings"
	"testing"

	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
)

func checkACLAvailability(c check) bool {
	return assert.FileExists(&testing.T{}, "/usr/bin/getfacl", "File ACLS is not supported")
}

func checkDifferentTokenInConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err, "error while reading configuration") {
		return false
	}

	return assert.Equal(c.test, "different"+c.installOptions.installToken, conf.Extensions.Sumologic.InstallationToken, "installation token is different than expected")
}

func checkDifferentTokenInEnvFile(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.installToken, "installation token has not been provided") {
		return false
	}

	envs, err := godotenv.Read(tokenEnvFilePath)

	if !assert.NoError(c.test, err) {
		return false
	}
	if _, ok := envs["SUMOLOGIC_INSTALL_TOKEN"]; ok {
		if !assert.Equal(c.test, "different"+c.installOptions.installToken, envs["SUMOLOGIC_INSTALL_TOKEN"], "installation token is different than expected") {
			return false
		}
	} else {
		if !assert.Equal(c.test, "different"+c.installOptions.installToken, envs["SUMOLOGIC_INSTALLATION_TOKEN"], "installation token is different than expected") {
			return false
		}
	}
	return true
}

func checkDownloadTimeout(c check) bool {
	output := strings.Join(c.errorOutput, "\n")
	count := strings.Count(output, "Operation timed out after")
	return assert.Equal(c.test, 6, count)
}

func checkHostmetricsOwnershipAndPermissions(ownerName string, ownerGroup string) func(c check) bool {
	return func(c check) bool {
		PathHasOwner(c.test, hostmetricsConfigPath, ownerName, ownerGroup)
		PathHasPermissions(c.test, hostmetricsConfigPath, configPathFilePermissions)
		return true
	}
}

func checkOutputUserAddWarnings(c check) bool {
	output := strings.Join(c.output, "\n")
	if !assert.NotContains(c.test, output, "useradd", "unexpected useradd output") {
		return false
	}

	errOutput := strings.Join(c.errorOutput, "\n")
	return assert.NotContains(c.test, errOutput, "useradd", "unexpected useradd output")
}

func checkTokenEnvFileCreated(c check) bool {
	return assert.FileExists(c.test, tokenEnvFilePath, "env token file has not been created")
}

func checkTokenEnvFileNotCreated(c check) bool {
	return assert.NoFileExists(c.test, tokenEnvFilePath, "env token file not been created")
}

func checkTokenInEnvFile(c check) bool {
	if !assert.NotEmpty(c.test, c.installOptions.installToken, "installation token has not been provided") {
		return false
	}

	envs, err := godotenv.Read(tokenEnvFilePath)

	if !assert.NoError(c.test, err) {
		return false
	}
	if _, ok := envs["SUMOLOGIC_INSTALL_TOKEN"]; ok {
		if !assert.Equal(c.test, c.installOptions.installToken, envs["SUMOLOGIC_INSTALL_TOKEN"], "installation token is different than expected") {
			return false
		}
	} else {
		if !assert.Equal(c.test, c.installOptions.installToken, envs["SUMOLOGIC_INSTALLATION_TOKEN"], "installation token is different than expected") {
			return false
		}
	}
	return true
}

func checkEphemeralInConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.True(c.test, c.installOptions.ephemeral, "ephemeral was not specified")

		_, err := os.Stat(p)
		return assert.NoError(c.test, err, "error while reading configuration")
	}
}

func checkEphemeralNotInConfig(p string) func(c check) bool {
	return func(c check) bool {
		assert.False(c.test, c.installOptions.ephemeral, "ephemeral was specified")

		_, err := os.Stat(p)
		if err == nil {
			c.test.Error("ephemeral in config")
			return false
		}
		return true
	}
}

func checkUninstallationOutput(c check) bool {
	if !assert.Greater(c.test, len(c.output), 1) {
		return false
	}
	return assert.Contains(c.test, c.output[len(c.output)-1], "Uninstallation completed")
}

func checkUserExists(c check) bool {
	_, err := user.Lookup(systemUser)
	return assert.NoError(c.test, err, "user has not been created")
}

func checkVarLogACL(c check) bool {
	if !checkACLAvailability(c) {
		return true
	}

	PathHasUserACL(c.test, "/var/log", systemUser, "r-x")
	return true
}

func preActionCreateHomeDirectory(c check) bool {
	err := os.MkdirAll(libPath, fs.FileMode(etcPathPermissions))
	return assert.NoError(c.test, err)
}

// preActionCreateUser creates the system user and then set it as owner of configPath
func preActionCreateUser(c check) bool {
	if !preActionMockUserConfig(c) {
		return false
	}

	cmd := exec.Command("useradd", systemUser)
	_, err := cmd.CombinedOutput()
	if !assert.NoError(c.test, err) {
		return false
	}

	f, err := os.Open(configPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	user, err := user.Lookup(systemUser)
	if !assert.NoError(c.test, err) {
		return false
	}

	uid, err := strconv.Atoi(user.Uid)
	if !assert.NoError(c.test, err) {
		return false
	}

	gid, err := strconv.Atoi(user.Gid)
	if !assert.NoError(c.test, err) {
		return false
	}

	err = f.Chown(uid, gid)
	return assert.NoError(c.test, err)
}

func preActionMockConfigs(c check) bool {
	if !preActionMockConfig(c) {
		return false
	}
	return preActionMockUserConfig(c)
}

func preActionMockEnvFiles(c check) bool {
	err := os.MkdirAll(envDirectoryPath, fs.FileMode(etcPathPermissions))
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

func preActionMockStructure(c check) bool {
	if !preActionMockConfigs(c) {
		return false
	}

	err := os.MkdirAll(fileStoragePath, os.ModePerm)
	if !assert.NoError(c.test, err) {
		return false
	}

	content := []byte("#!/bin/sh\necho hello world\n")
	err = os.WriteFile(binaryPath, content, 0755)
	return assert.NoError(c.test, err)
}

func preActionWriteDefaultAPIBaseURLToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.APIBaseURL = apiBaseURL
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteDifferentDeprecatedTokenToEnvFile(c check) bool {
	if !preActionMockEnvFiles(c) {
		return false
	}

	content := fmt.Sprintf("SUMOLOGIC_INSTALL_TOKEN=different%s", c.installOptions.installToken)
	err := os.WriteFile(tokenEnvFilePath, []byte(content), fs.FileMode(etcPathPermissions))
	return assert.NoError(c.test, err)
}

func preActionWriteDifferentTokenToEnvFile(c check) bool {
	if !preActionMockEnvFiles(c) {
		return false
	}

	content := fmt.Sprintf("SUMOLOGIC_INSTALLATION_TOKEN=different%s", c.installOptions.installToken)
	err := os.WriteFile(tokenEnvFilePath, []byte(content), fs.FileMode(etcPathPermissions))
	return assert.NoError(c.test, err)
}

func preActionWriteDifferentTokenToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.InstallationToken = "different" + c.installOptions.installToken
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}

func preActionWriteTokenToUserConfig(c check) bool {
	conf, err := getConfig(userConfigPath)
	if !assert.NoError(c.test, err) {
		return false
	}

	conf.Extensions.Sumologic.InstallationToken = c.installOptions.installToken
	err = saveConfig(userConfigPath, conf)
	return assert.NoError(c.test, err)
}
