package main

import (
	resty "github.com/go-resty/resty/v2"
	log "github.com/sirupsen/logrus"
)

type PackageRemover struct {
	client *resty.Client
}

func (r *PackageRemover) RemovePackage(pkg Package) error {
	logger := log.WithFields(log.Fields{
		"name":           pkg.Name,
		"distro_version": pkg.DistroVersion,
		"version":        pkg.Version,
		"release":        pkg.Release,
		"epoch":          pkg.Epoch,
		"age":            pkg.DaysOld(),
		"age_max":        maxAge,
	})

	logger.Info("removing package that exceeds max age")

	resp, err := r.client.R().Delete(pkg.DestroyURL)
	if err != nil {
		return err
	}

	if resp.IsError() {
		return handleRestyError(resp, err)
	}

	return nil
}
