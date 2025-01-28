package main

import "time"

type Package struct {
	Name          string    `json:"name"`
	DistroVersion string    `json:"distro_version"`
	CreatedAt     time.Time `json:"created_at"`
	Version       string    `json:"version"`
	Release       string    `json:"release"`
	Epoch         int       `json:"epoch"`
	DestroyURL    string    `json:"destroy_url"`
}

func (p *Package) DaysOld() int {
	return int(time.Since(p.CreatedAt).Hours() / 24)
}

func (p *Package) OlderThan(days int) bool {
	return p.DaysOld() >= days
}
