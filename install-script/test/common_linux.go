// go:

package sumologic_scripts_tests

import (
	"testing"
)

func tearDown(t *testing.T) {
	ch := check{
		test: t,
		installOptions: installOptions{
			uninstall: true,
		},
	}

	_, _, _, err := runScript(ch)
	if err != nil {
		t.Log(err)
	}
	return
}
