mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  ?= $(patsubst %/,%,$(dir $(mkfile_path)))
build_dir   ?= $(mkfile_dir)/build

OTC_ARTIFACTS_SOURCE ?= github-artifacts

ifeq ($(strip $(PACKAGECLOUD_TOKEN)),)
$(error "PACKAGECLOUD_TOKEN must be set")
endif

.PHONY: docker-image
docker-image:
	docker buildx bake --load

.PHONY: build
build: docker-image
build:
	docker run \
		-e TARGET="$(TARGET)" \
		-e OTC_VERSION="$(OTC_VERSION)" \
		-e OTC_SUMO_VERSION="$(OTC_SUMO_VERSION)" \
		-e OTC_BUILD_NUMBER="$(OTC_BUILD_NUMBER)" \
		-e OTC_ARTIFACTS_SOURCE="$(OTC_ARTIFACTS_SOURCE)" \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		otelcol-sumo/cmake \
		cmake /src

.PHONY: package
package: build
package:
	docker run \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		otelcol-sumo/cmake \
		make package

.PHONY: publish-package
publish-package: package
publish-package:
	docker run \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		-e PACKAGECLOUD_TOKEN="$(PACKAGECLOUD_TOKEN)" \
		otelcol-sumo/cmake \
		make publish-package

.PHONY: otc_linux_amd64_deb
otc_linux_amd64_deb: TARGET = otc_linux_amd64_deb
otc_linux_amd64_deb: publish-package

.PHONY: otc_linux_arm64_deb
otc_linux_arm64_deb: TARGET = otc_linux_arm64_deb
otc_linux_arm64_deb: publish-package

.PHONY: otc_linux_amd64_rpm
otc_linux_amd64_rpm: TARGET = otc_linux_amd64_rpm
otc_linux_amd64_rpm: publish-package

.PHONY: otc_linux_arm64_rpm
otc_linux_arm64_rpm: TARGET = otc_linux_arm64_rpm
otc_linux_arm64_rpm: publish-package

.PHONY: all-targets
all-targets:
	$(MAKE) otc_linux_amd64_deb
	$(MAKE) otc_linux_arm64_deb
	$(MAKE) otc_linux_amd64_rpm
	$(MAKE) otc_linux_arm64_rpm
