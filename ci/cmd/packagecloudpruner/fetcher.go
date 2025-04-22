package main

import (
	"net/url"
	"strconv"

	resty "github.com/go-resty/resty/v2"
	linkparser "github.com/peterhellberg/link"
	log "github.com/sirupsen/logrus"
)

type PackageFetcher struct {
	client      *resty.Client
	nextPageURL string
	perPage     string
}

func (p *PackageFetcher) HasNextPage() bool {
	return p.nextPageURL != ""
}

func (p *PackageFetcher) RequestCurrentPage() ([]Package, error) {
	packagesToRemove := []Package{}

	log.Info("fetching next page of packages")

	if p.perPage == "" {
		p.perPage = defaultPerPage
	}

	// request the page of packages
	resp, err := p.client.R().
		SetResult([]Package{}).
		SetQueryParam("per_page", p.perPage).
		Get(p.nextPageURL)
	if err != nil {
		return packagesToRemove, err
	}
	if resp.IsError() {
		return packagesToRemove, handleRestyError(resp, err)
	}

	// loop through the packages and remove them if the time since creation
	// is 30 days or more
	for _, pkg := range *resp.Result().(*[]Package) {
		log.WithFields(log.Fields{
			"name":         pkg.Name,
			"version":      pkg.Version,
			"build_number": pkg.Release,
			"distro":       pkg.DistroVersion,
		}).Info("found package to evaluate")

		if pkg.OlderThan(maxAge) {
			packagesToRemove = append(packagesToRemove, pkg)
		}
	}

	headers := resp.Header()
	p.perPage = headers.Get("Max-Per-Page")

	var nextPageStr string
	var lastPageStr string

	// RFC-5988 links for pagination. Possible rel values are: next, previous, last.
	for _, link := range linkparser.ParseHeader(headers) {
		uri, err := url.Parse(link.URI)
		if err != nil {
			return packagesToRemove, err
		}

		queryParams := uri.Query()
		pageParam := queryParams.Get("page")

		if link.Rel == "next" {
			p.nextPageURL = link.URI
			nextPageStr = pageParam
		}

		if link.Rel == "last" {
			lastPageStr = pageParam
		}
	}

	if nextPageStr != "" && lastPageStr != "" {
		nextPage, err := strconv.Atoi(nextPageStr)
		if err != nil {
			return packagesToRemove, err
		}

		lastPage, err := strconv.Atoi(lastPageStr)
		if err != nil {
			return packagesToRemove, err
		}

		pagesRemaining := lastPage - nextPage

		log.WithFields(log.Fields{
			"next_page":       nextPage,
			"last_page":       lastPage,
			"pages_remaining": pagesRemaining,
			"per_page":        p.perPage,
		}).Infof("successfully fetched page %d of %d", nextPage-1, lastPage)
	} else {
		p.nextPageURL = ""

		log.WithFields(log.Fields{
			"age_max": maxAge,
		}).Info("finished fetching package list")
	}

	return packagesToRemove, nil
}
