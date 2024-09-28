//go:build windows

package sumologic_scripts_tests

import (
	"context"
	"fmt"
	"os/exec"
	"testing"
)

// These checks always have to be true after a script execution
var commonPostChecks = []checkFunc{checkNoBakFilesPresent}

func runTest(t *testing.T, spec *testSpec) (fErr error) {
	ch := check{
		test:                t,
		installOptions:      spec.options,
		expectedInstallCode: spec.installCode,
	}

	t.Log("Running conditional checks")
	for _, a := range spec.conditionalChecks {
		if !a(ch) {
			t.SkipNow()
		}
	}

	defer tearDown(t)

	mockAPI, err := startMockAPI(t)
	if err != nil {
		return fmt.Errorf("Failed to start mock API: %s", err)
	}

	defer func() {
		if err := mockAPI.Shutdown(context.Background()); err != nil {
			fErr = fmt.Errorf("Failed to shutdown API: %s", err)
			return
		}
	}()

	t.Log("Running pre actions")
	for _, a := range spec.preActions {
		if ok := a(ch); !ok {
			return nil
		}
	}

	t.Log("Running pre checks")
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

	t.Log("Running common post checks")
	for _, c := range commonPostChecks {
		if ok := c(ch); !ok {
			return nil
		}
	}

	t.Log("Running post checks")
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
		t.Log(string(out))
	}
}
