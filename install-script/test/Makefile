ifeq ($(OS),Windows_NT)
	OS=windows
endif

ifneq ($(OS),windows)
	GOTESTPREFIX ?= sudo env PATH="${PATH}" GH_CI_TOKEN="${GITHUB_TOKEN}" DARWIN_PKG_URL="${DARWIN_PKG_URL}" PACKAGECLOUD_MASTER_TOKEN="${PACKAGECLOUD_MASTER_TOKEN}" PACKAGECLOUD_REPO="${PACKAGECLOUD_REPO}" OTC_VERSION="${OTC_VERSION}" OTC_BUILD_NUMBER="${OTC_BUILD_NUMBER}"
endif

LINT=golangci-lint
GOTEST=go test
GOTESTBINARY=sumologic_scripts_tests.test
GOTESTNAME ?= ""
GOTESTRUN=

ifneq ($(GOTESTNAME),"")
	GOTESTRUN=-test.run $(GOTESTNAME)
endif

# We build the test binary separately to avoid downloading modules as root
.PHONY: test
test:
	$(GOTEST) -c
	$(GOTESTPREFIX) ./$(GOTESTBINARY) -test.v $(GOTESTRUN)

.PHONY: fmt
fmt:
	gofmt  -w -s ./
	goimports -w  ./

.PHONY: lint
lint:
	$(LINT) run

.PHONY: mod-download-all
mod-download-all:
	go mod download all && go mod tidy
