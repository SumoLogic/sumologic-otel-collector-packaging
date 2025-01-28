package main

import (
	"testing"

	resty "github.com/go-resty/resty/v2"
)

func Test_handleRestyError(t *testing.T) {
	type args struct {
		resp *resty.Response
		i    interface{}
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if err := handleRestyError(tt.args.resp, tt.args.i); (err != nil) != tt.wantErr {
				t.Errorf("handleRestyError() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func Test_main(t *testing.T) {
	tests := []struct {
		name string
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			main()
		})
	}
}
