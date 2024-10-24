package sumologic_scripts_tests

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func dsclDeletePath(t *testing.T, path string) bool {
	cmd := exec.Command("dscl", ".", "-delete", path)
	output, err := cmd.CombinedOutput()
	if !assert.NoErrorf(t, err, "error while using dscl to delete path: %s, path: %s", output, path) {
		return false
	}
	return assert.Empty(t, string(output))
}

// The user.Lookup() and user.LookupGroup() functions do not appear to work
// correctly on Darwin. The functions will still return a user or group after it
// has been deleted. There are several GitHub issues in github.com/golang/go
// that describe similar or related behaviour. To work around this issue we use
// the dscl command to determine if a user or group exists.
func dsclKeyExistsForPath(t *testing.T, path, key string) (bool, error) {
	cmd := exec.Command("dscl", ".", "-list", path)
	out, err := cmd.StdoutPipe()
	if err != nil {
		return false, err
	}
	defer out.Close()

	bufOut := bufio.NewReader(out)

	if err := cmd.Start(); err != nil {
		return false, err
	}

	for {
		line, _, err := bufOut.ReadLine()

		if string(line) == key {
			return true, nil
		}

		// exit if script finished
		if err == io.EOF {
			break
		}

		// otherwise ensure there is no error
		if err != nil {
			return false, err
		}
	}

	return false, nil
}

func forgetPackage(t *testing.T, name string) error {
	noReceiptMsg := fmt.Sprintf("No receipt for '%s' found at '/'.", name)

	output, err := exec.Command("pkgutil", "--forget", name).CombinedOutput()
	if err != nil && !strings.Contains(string(output), noReceiptMsg) {
		return fmt.Errorf("error forgetting package: %s", string(output))
	}
	return nil
}

func removeFileIfExists(t *testing.T, path string) error {
	if _, err := os.Stat(path); err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	if err := os.Remove(path); err != nil {
		return fmt.Errorf("error removing file: %s", path)
	}
	return nil
}

func removeDirectoryIfExists(t *testing.T, path string) error {
	info, err := os.Stat(path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	if !info.IsDir() {
		return fmt.Errorf("path is not a directory: %s", path)
	}
	if err := os.RemoveAll(path); err != nil {
		return fmt.Errorf("error removing directory: %s", path)
	}
	return nil
}

func tearDown(t *testing.T) {
	// Stop service
	if err := unloadLaunchdService(t); err != nil {
		t.Log(err)
	}

	// Remove files
	if err := removeFileIfExists(t, binaryPath); err != nil {
		t.Log(err)
	}
	if err := removeFileIfExists(t, launchdPath); err != nil {
		t.Log(err)
	}

	// Remove configuration & data
	if err := removeDirectoryIfExists(t, etcPath); err != nil {
		t.Log(err)
	}
	if err := removeDirectoryIfExists(t, fileStoragePath); err != nil {
		t.Log(err)
	}
	if err := removeDirectoryIfExists(t, logDirPath); err != nil {
		t.Log(err)
	}
	if err := removeDirectoryIfExists(t, appSupportDirPath); err != nil {
		t.Log(err)
	}

	// Remove user & group
	if exists, err := dsclKeyExistsForPath(t, "/Users", systemUser); err != nil {
		t.Log(err)
	} else if exists {
		dsclDeletePath(t, fmt.Sprintf("/Users/%s", systemUser))
	}

	if exists, err := dsclKeyExistsForPath(t, "/Groups", systemGroup); err != nil {
		t.Log(err)
	} else if exists {
		dsclDeletePath(t, fmt.Sprintf("/Groups/%s", systemGroup))
	}

	if exists, err := dsclKeyExistsForPath(t, "/Users", systemUser); err != nil {
		t.Log(err)
	} else if exists {
		panic(fmt.Sprintf("user exists after deletion: %s", systemUser))
	}

	if exists, err := dsclKeyExistsForPath(t, "/Groups", systemGroup); err != nil {
		t.Log(err)
	} else if exists {
		panic(fmt.Sprintf("group exists after deletion: %s", systemGroup))
	}

	// Remove packages
	if err := forgetPackage(t, "com.sumologic.otelcol-sumo"); err != nil {
		t.Log(err)
	}
}

func unloadLaunchdService(t *testing.T) error {
	info, err := os.Stat(launchdPath)
	if err != nil {
		if os.IsNotExist(err) {
			return nil
		}
		return err
	}

	if info.IsDir() {
		return fmt.Errorf("launchd config is a directory: %s", launchdPath)
	}

	output, err := exec.Command("launchctl", "unload", "-w", "otelcol-sumo").Output()
	if err != nil {
		fmt.Errorf("error stopping service: %s", string(output))
	}
	return nil
}
