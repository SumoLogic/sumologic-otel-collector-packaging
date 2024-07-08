package sumologic_scripts_tests

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"os"
)

const (
	GithubOrg           = "SumoLogic"
	GithubAppRepository = "sumologic-otel-collector"
	GithubApiBaseUrl    = "https://api.github.com"

	StagingInstallationLogfileEndpoint string = "https://stag-open-events.sumologic.net/api/v1/collector/installation/logs"
)

var (
	latestAppVersion string
)

func authenticateGithub() string {
	githubToken := os.Getenv("GITHUB_TOKEN")
	if githubToken == "" {
		fmt.Println("Error: GitHub token not found in environment variables")
		os.Exit(1)
	}
	return githubToken
}

func getLatestAppReleaseVersion() (string, error) {
	githubApiBaseUrl, err := url.Parse(GithubApiBaseUrl)
	if err != nil {
		return "", err
	}
	githubToken := authenticateGithub()

	githubApiLatestReleaseUrl := fmt.Sprintf("%s/repos/%s/%s/releases/latest", githubApiBaseUrl, GithubOrg, GithubAppRepository)

	req, err := http.NewRequest("GET", githubApiLatestReleaseUrl, nil)
	if err != nil {
		return "", err
	}

	// Set Authorization header with GitHub token
	req.Header.Set("Authorization", "token "+githubToken)
	req.Header.Set("Accept", "application/vnd.github.v3+json")

	// Send request
	client := http.Client{}
	response, err := client.Do(req)
	if err != nil {
		return "", err
	}
	defer response.Body.Close()

	if response.StatusCode != http.StatusOK {
		return "", fmt.Errorf("failed to get release: %s", response.Status)
	}

	var release struct {
		TagName string `json:"tag_name"`
	}
	decoder := json.NewDecoder(response.Body)
	err = decoder.Decode(&release)
	if err != nil {
		return "", err
	}

	return release.TagName, nil
}

func init() {
	latestReleaseVersion, err := getLatestAppReleaseVersion()
	if err != nil {
		fmt.Printf("error fetching release: %v", err)
		os.Exit(1)
	}
	if latestReleaseVersion == "" {
		fmt.Println("No app release versions found")
		os.Exit(1)
	}
	latestAppVersion = latestReleaseVersion
}
