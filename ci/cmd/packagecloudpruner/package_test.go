package main

import (
	"testing"
	"time"
)

func TestPackage_DaysOld(t *testing.T) {
	type fields struct {
		Name          string
		DistroVersion string
		CreatedAt     time.Time
		Version       string
		Release       string
		Epoch         int
		DestroyURL    string
	}
	tests := []struct {
		name   string
		fields fields
		want   int
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			p := &Package{
				Name:          tt.fields.Name,
				DistroVersion: tt.fields.DistroVersion,
				CreatedAt:     tt.fields.CreatedAt,
				Version:       tt.fields.Version,
				Release:       tt.fields.Release,
				Epoch:         tt.fields.Epoch,
				DestroyURL:    tt.fields.DestroyURL,
			}
			if got := p.DaysOld(); got != tt.want {
				t.Errorf("Package.DaysOld() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestPackage_OlderThan(t *testing.T) {
	type fields struct {
		Name          string
		DistroVersion string
		CreatedAt     time.Time
		Version       string
		Release       string
		Epoch         int
		DestroyURL    string
	}
	type args struct {
		days int
	}
	tests := []struct {
		name   string
		fields fields
		args   args
		want   bool
	}{
		// TODO: Add test cases.
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			p := &Package{
				Name:          tt.fields.Name,
				DistroVersion: tt.fields.DistroVersion,
				CreatedAt:     tt.fields.CreatedAt,
				Version:       tt.fields.Version,
				Release:       tt.fields.Release,
				Epoch:         tt.fields.Epoch,
				DestroyURL:    tt.fields.DestroyURL,
			}
			if got := p.OlderThan(tt.args.days); got != tt.want {
				t.Errorf("Package.OlderThan() = %v, want %v", got, tt.want)
			}
		})
	}
}
