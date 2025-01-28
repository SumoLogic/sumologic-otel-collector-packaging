package main

import (
	"reflect"
	"testing"

	resty "github.com/go-resty/resty/v2"
)

func TestPackageFetcher_HasNextPage(t *testing.T) {
	type fields struct {
		client      *resty.Client
		nextPageURL string
		perPage     string
	}
	tests := []struct {
		name   string
		fields fields
		want   bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			p := &PackageFetcher{
				client:      tt.fields.client,
				nextPageURL: tt.fields.nextPageURL,
				perPage:     tt.fields.perPage,
			}
			if got := p.HasNextPage(); got != tt.want {
				t.Errorf("PackageFetcher.HasNextPage() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestPackageFetcher_RequestCurrentPage(t *testing.T) {
	type fields struct {
		client      *resty.Client
		nextPageURL string
		perPage     string
	}
	tests := []struct {
		name    string
		fields  fields
		want    []Package
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			p := &PackageFetcher{
				client:      tt.fields.client,
				nextPageURL: tt.fields.nextPageURL,
				perPage:     tt.fields.perPage,
			}
			got, err := p.RequestCurrentPage()
			if (err != nil) != tt.wantErr {
				t.Errorf("PackageFetcher.RequestCurrentPage() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("PackageFetcher.RequestCurrentPage() = %v, want %v", got, tt.want)
			}
		})
	}
}
