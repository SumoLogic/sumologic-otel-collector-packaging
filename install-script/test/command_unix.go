//go:build linux || darwin

package sumologic_scripts_tests

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
)

type installOptions struct {
	installToken       string
	autoconfirm        bool
	tags               map[string]string
	skipInstallToken   bool
	fips               bool
	envs               map[string]string
	uninstall          bool
	apiBaseURL         string
	installHostmetrics bool
	remotelyManaged    bool
	ephemeral          bool
	timeout            float64
	opampEndpoint      string
	downloadOnly       bool
	dontKeepDownloads  bool
	version            string
	timezone           string
}

func (io *installOptions) string() []string {
	opts := []string{
		scriptPath,
	}

	if io.autoconfirm {
		opts = append(opts, "--yes")
	}

	if io.fips {
		opts = append(opts, "--fips")
	}

	if io.downloadOnly {
		opts = append(opts, "--download-only")
	}

	if io.skipInstallToken {
		opts = append(opts, "--skip-installation-token")
	}

	if io.uninstall {
		opts = append(opts, "--uninstall")
		opts = append(opts, "--purge")
	}

	if io.installHostmetrics {
		opts = append(opts, "--install-hostmetrics")
	}

	if io.remotelyManaged {
		opts = append(opts, "--remotely-managed")
	}

	if io.ephemeral {
		opts = append(opts, "--ephemeral")
	}

	if io.timezone != "" {
		opts = append(opts, "--timezone", io.timezone)
	}

	if len(io.tags) > 0 {
		for k, v := range io.tags {
			opts = append(opts, "--tag", fmt.Sprintf("%s=%s", k, v))
		}
	}

	// 1. If the apiBaseURL is empty, replace it with the mock API's URL.
	// 2. If the apiBaseURL is equal to the emptyAPIBaseURL constant, don't set
	//    the --api flag.
	// 3. If none of the above are true, set the --api flag to the value of
	//    apiBaseURL.
	apiBaseURL := ""
	if io.apiBaseURL == "" {
		apiBaseURL = mockAPIBaseURL
	} else if io.apiBaseURL != emptyAPIBaseURL {
		apiBaseURL = io.apiBaseURL
	}
	if apiBaseURL != "" {
		opts = append(opts, "--api", apiBaseURL)
	}

	if io.timeout != 0 {
		opts = append(opts, "--download-timeout", fmt.Sprintf("%f", io.timeout))
	}

	if io.opampEndpoint != "" {
		opts = append(opts, "--opamp-api", io.opampEndpoint)
	}

	otc_version := os.Getenv("OTC_VERSION")
	otc_build_number := os.Getenv("OTC_BUILD_NUMBER")

	if io.version != "" {
		opts = append(opts, "--version", io.version)
	} else if otc_version != "" && otc_build_number != "" {
		opts = append(opts, "--version", fmt.Sprintf("%s-%s", otc_version, otc_build_number))
	}

	return opts
}

func (io *installOptions) buildEnvs() []string {
	e := os.Environ()

	for k, v := range io.envs {
		e = append(e, fmt.Sprintf("%s=%s", k, v))
	}

	if io.installToken != "" {
		e = append(e, fmt.Sprintf("%s=%s", installTokenEnv, io.installToken))
	}

	return e
}

func exitCode(cmd *exec.Cmd) (int, error) {
	err := cmd.Wait()

	if err == nil {
		return cmd.ProcessState.ExitCode(), nil
	}

	if exiterr, ok := err.(*exec.ExitError); ok {
		return exiterr.ExitCode(), nil
	}

	return 0, fmt.Errorf("cannot obtain exit code: %v", err)
}

func runScript(ch check) (int, []string, []string, error) {
	cmd := exec.Command("bash", ch.installOptions.string()...)
	cmd.Env = ch.installOptions.buildEnvs()
	output := []string{}

	ch.test.Logf("Running command: %s", strings.Join(ch.installOptions.string(), " "))

	in, err := cmd.StdinPipe()
	if err != nil {
		return 0, nil, nil, err
	}

	defer in.Close()

	out, err := cmd.StdoutPipe()
	if err != nil {
		return 0, nil, nil, err
	}
	defer out.Close()

	errOut, err := cmd.StderrPipe()
	if err != nil {
		return 0, nil, nil, err
	}
	defer errOut.Close()

	// We want to read line by line
	bufOut := bufio.NewReader(out)

	// Start the process
	if err = cmd.Start(); err != nil {
		return 0, nil, nil, err
	}

	// Read the results from the process
	for {
		line, _, err := bufOut.ReadLine()
		strLine := strings.TrimSpace(string(line))

		if len(strLine) > 0 {
			output = append(output, strLine)
		}
		ch.test.Log(strLine)

		// exit if script finished
		if err == io.EOF {
			break
		}

		// otherwise ensure there is no error
		if err != nil {
			return 0, nil, nil, err
		}
	}

	// Handle stderr separately
	bufErrOut := bufio.NewReader(errOut)
	errorOutput := []string{}
	for {
		line, _, err := bufErrOut.ReadLine()
		strLine := strings.TrimSpace(string(line))

		if len(strLine) > 0 {
			errorOutput = append(errorOutput, strLine)
		}
		ch.test.Log(strLine)

		// exit if script finished
		if err == io.EOF {
			break
		}
	}

	code, err := exitCode(cmd)
	return code, output, errorOutput, err
}
