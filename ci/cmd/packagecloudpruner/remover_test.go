package main

import (
	"testing"

	resty "github.com/go-resty/resty/v2"
)

func TestPackageRemover_RemovePackage(t *testing.T) {
	type fields struct {
		client *resty.Client
	}
	type args struct {
		pkg Package
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := &PackageRemover{
				client: tt.fields.client,
			}
			if err := r.RemovePackage(tt.args.pkg); (err != nil) != tt.wantErr {
				t.Errorf("PackageRemover.RemovePackage() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}
