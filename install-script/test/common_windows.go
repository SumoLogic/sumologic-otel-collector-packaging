//go:build windows

package sumologic_scripts_tests

import (
	"context"
	"fmt"
	"os/exec"
	"strings"
	"testing"
	"time"
)

// These checks always have to be true after a script execution
var commonPostChecks = []checkFunc{checkNoBakFilesPresent}

func runTest(t *testing.T, spec *testSpec) (fErr error) {
	ch := check{
		test:                t,
		installOptions:      spec.options,
		expectedInstallCode: spec.installCode,
	}

	t.Log(time.Now(), "Running conditional checks")
	for _, a := range spec.conditionalChecks {
		if !a(ch) {
			t.SkipNow()
		}
	}

	defer tearDown(t)

	mockAPI, err := startMockAPI(t)
	if err != nil {
		return fmt.Errorf("Failed to start mock API: %w", err)
	}

	defer func() {
		if err := mockAPI.Shutdown(context.Background()); err != nil {
			fErr = fmt.Errorf("Failed to shutdown API: %w", err)
			return
		}
	}()

	t.Log(time.Now(), "Running pre actions")
	for _, a := range spec.preActions {
		if ok := a(ch); !ok {
			return nil
		}
	}

	// Run setup script if setupOptions is provided (e.g. install before uninstall/upgrade)
	if spec.setupOptions != nil {
		t.Log(time.Now(), "Running setup script")
		setupCh := check{
			test:                t,
			installOptions:      *spec.setupOptions,
			expectedInstallCode: 0,
		}
		setupCode, setupOut, setupErrOut, setupErr := runScript(setupCh)
		if setupErr != nil {
			return fmt.Errorf("setup script error: %w", setupErr)
		}
		if setupCode != 0 {
			return fmt.Errorf("setup script failed with exit code: %d\nstdout:\n%s\nstderr:\n%s",
				setupCode, strings.Join(setupOut, "\n"), strings.Join(setupErrOut, "\n"))
		}
		// Wait for the Windows Installer service to release the MSI mutex.
		// Without this delay, subsequent MSI operations may fail with exit
		// code 1618 ("Another installation is already in progress").
		t.Log(time.Now(), "Waiting for Windows Installer service to release MSI mutex")
		time.Sleep(15 * time.Second)
	}

	t.Log(time.Now(), "Running pre checks")
	for _, c := range spec.preChecks {
		if ok := c(ch); !ok {
			return nil
		}
	}

	ch.code, ch.output, ch.errorOutput, ch.err = runScript(ch)
	if err != nil {
		return err
	}

	checkRun(ch)

	t.Log(time.Now(), "Running common post checks")
	for _, c := range commonPostChecks {
		if ok := c(ch); !ok {
			return nil
		}
	}

	t.Log(time.Now(), "Running post checks")
	for _, c := range spec.postChecks {
		if ok := c(ch); !ok {
			return nil
		}
	}
	return nil
}

func tearDown(t *testing.T) {
	cmd := exec.Command("powershell", "Uninstall-Package", "-Name", fmt.Sprintf(`"%s"`, packageName))
	if out, err := cmd.CombinedOutput(); err != nil {
		t.Log(time.Now(), string(out))
	}
}
