package sumologic_scripts_tests

import (
	"log"
	"os"
)

const (
	GithubOrg           = "SumoLogic"
	GithubAppRepository = "sumologic-otel-collector"
	GithubApiBaseUrl    = "https://api.github.com"
)

func authenticateGithub() string {
	githubToken := os.Getenv("GH_CI_TOKEN")
	if githubToken == "" {
		log.Fatal("GITHUB_TOKEN environment variable not set")

	}
	return githubToken
}
