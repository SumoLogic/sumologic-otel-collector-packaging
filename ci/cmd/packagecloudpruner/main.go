package main

import (
	"fmt"
	"net/http"
	"os"

	retry "github.com/avast/retry-go"
	resty "github.com/go-resty/resty/v2"
	log "github.com/sirupsen/logrus"
)

const (
	baseURL          = "https://packagecloud.io"
	user             = "sumologic"
	repository       = "ci-builds"
	retryMaxAttempts = 5
	maxAge           = 30 // in days
	defaultPerPage   = "250"
)

type ResponseError struct {
	Status int
	Error  string
}

func handleRestyError(resp *resty.Response, i interface{}) error {
	err := *resp.Error().(*ResponseError)
	errStatus := err.Status
	errMsg := err.Error
	if errStatus == 0 {
		errStatus = resp.StatusCode()
	}
	if errMsg == "" {
		errMsg = resp.Status()
	}
	if errStatus == http.StatusNotFound {
		// ignore 404 status for DELETE method
		if resp.Request.Method == resty.MethodDelete {
			log.WithFields(log.Fields{
				"url":     resp.Request.URL,
				"method":  resp.Request.Method,
				"status":  errStatus,
				"message": errMsg,
			}).Warn("not found, ignoring")
			return nil
		}
	}
	return fmt.Errorf("status: %d, error: %s", errStatus, errMsg)
}

func main() {
	token := os.Getenv("PACKAGECLOUD_TOKEN")
	if token == "" {
		log.Fatal("the environment variable PACKAGECLOUD_TOKEN must be set")
	}

	globalHeaders := map[string]string{
		"Content-Type": "application/json",
	}

	client := resty.New()
	client.SetBasicAuth(token, "")
	client.SetHostURL(baseURL)
	client.SetHeaders(globalHeaders)
	client.SetError(&ResponseError{})

	fetcher := PackageFetcher{
		client:      client,
		nextPageURL: fmt.Sprintf("/api/v1/repos/%s/%s/packages.json", user, repository),
	}

	packagesToRemove := []Package{}

	for fetcher.HasNextPage() {
		err := retry.Do(
			func() error {
				packages, err := fetcher.RequestCurrentPage()
				if err != nil {
					return err
				}
				packagesToRemove = append(packagesToRemove, packages...)
				return nil
			},
			retry.Attempts(retryMaxAttempts),
			retry.OnRetry(func(n uint, err error) {
				log.WithFields(log.Fields{
					"error": err,
				}).
					Errorf("attempt #%d to fetch package list failed - retrying", n)
			}),
		)
		if err != nil {
			log.WithFields(log.Fields{
				"error": err,
			}).Fatal("failed to fetch list of packages")
			os.Exit(1)
		}
	}

	packagesLen := len(packagesToRemove)
	if packagesLen == 0 {
		log.Infof("no packages exceeded the max age of %d days", maxAge)
		return
	}

	log.Infof("found %d packages exceeding the max age of %d days", len(packagesToRemove), maxAge)

	remover := PackageRemover{
		client: client,
	}

	for _, pkg := range packagesToRemove {
		logger := log.WithFields(log.Fields{
			"name":    pkg.Name,
			"distro":  pkg.DistroVersion,
			"version": pkg.Version,
			"release": pkg.Release,
			"epoch":   pkg.Epoch,
		})
		err := retry.Do(
			func() error {
				return remover.RemovePackage(pkg)
			},
			retry.Attempts(retryMaxAttempts),
			retry.OnRetry(func(n uint, err error) {
				logger.WithFields(log.Fields{
					"error": err,
				}).Errorf("attempt #%d to remove package failed - retrying", n)
			}),
		)
		if err != nil {
			logger.WithFields(log.Fields{
				"error": err,
			}).Fatal("failed to remove package - skipping")
		}
	}
}
