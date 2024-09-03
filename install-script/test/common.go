package sumologic_scripts_tests

import (
	"io"
	"net"
	"net/http"
	"testing"
)

type testSpec struct {
	name              string
	options           installOptions
	preChecks         []checkFunc
	postChecks        []checkFunc
	preActions        []checkFunc
	conditionalChecks []condCheckFunc
	installCode       int
}

func startMockAPI(t *testing.T) (*http.Server, error) {
	t.Log("Starting HTTP server")
	mux := http.NewServeMux()
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if _, err := io.WriteString(w, "200 OK\n"); err != nil {
			panic(err)
		}
	})

	listener, err := net.Listen("tcp", ":3333")
	if err != nil {
		return nil, err
	}

	httpServer := &http.Server{
		Handler: mux,
	}
	go func() {
		err := httpServer.Serve(listener)
		if err != nil && err != http.ErrServerClosed {
			panic(err)
		}
	}()
	return httpServer, nil
}
