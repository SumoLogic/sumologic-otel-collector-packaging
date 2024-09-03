package sumologic_scripts_tests

import (
	"log"
	"os"
)

const (
	GithubOrg           = "SumoLogic"
	GithubAppRepository = "sumologic-otel-collector"
	GithubApiBaseUrl    = "https://api.github.com"

	mockAPIBaseURL  = "http://127.0.0.1:3333"
	emptyAPIBaseURL = "empty"
)

func authenticateGithub() string {
	githubToken := os.Getenv("GH_CI_TOKEN")
	if githubToken == "" {
		log.Fatal("GITHUB_TOKEN environment variable not set")

	}
	return githubToken
}
