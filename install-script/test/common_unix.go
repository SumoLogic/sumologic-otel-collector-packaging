//go:build linux || darwin

package sumologic_scripts_tests

import (
	"context"
	"fmt"
	"os"
	"testing"
)

// These checks always have to be true after a script execution
var commonPostChecks = []checkFunc{checkNoBakFilesPresent}

func cleanCache(t *testing.T) error {
	return os.RemoveAll(cacheDirectory)
}

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

	t.Log("Running script")
	ch.code, ch.output, ch.errorOutput, ch.err = runScript(ch)
	if ch.err != nil {
		return ch.err
	}

	// Remove cache in case of curl issue
	if ch.code == curlTimeoutErrorCode {
		if err := cleanCache(t); err != nil {
			return err
		}
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
