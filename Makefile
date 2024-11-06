mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  ?= $(patsubst %/,%,$(dir $(mkfile_path)))
build_dir   ?= $(mkfile_dir)/build

require-%:
	@: $(if ${${*}},,$(error Required environment variable was not found: $*))
	@echo 'Required environment variable was found: $*'

.PHONY: docker-image
docker-image:
	docker buildx bake --load

.PHONY: version-artifact
version-artifact: require-GH_TOKEN
version-artifact: require-GH_WORKFLOW_ID
version-artifact: docker-image
version-artifact:
	docker run \
		-e GH_TOKEN="$(GH_TOKEN)" \
		-e GH_WORKFLOW_ID="$(GH_WORKFLOW_ID)" \
		-e WORK_DIR="/src" \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		otelcol-sumo/cmake \
		cmake -P version_artifact.cmake

.PHONY: generate
generate: require-TARGET
generate: require-OTC_BUILD_NUMBER
generate: require-GH_TOKEN
generate: require-GH_WORKFLOW_ID
generate: version-artifact
generate:
	docker run \
		-e TARGET="$(TARGET)" \
		-e OTC_BUILD_NUMBER="$(OTC_BUILD_NUMBER)" \
		-e GH_TOKEN="$(GH_TOKEN)" \
		-e GH_WORKFLOW_ID="$(GH_WORKFLOW_ID)" \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		otelcol-sumo/cmake \
		cmake /src

.PHONY: build
build: generate
build:
	docker run \
		-e GH_TOKEN="$(GH_TOKEN)" \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		otelcol-sumo/cmake \
		make

.PHONY: package
package: build
package:
	docker run \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		otelcol-sumo/cmake \
		make package

.PHONY: publish-package
publish-package: require-PACKAGECLOUD_TOKEN
publish-package: package
publish-package:
	docker run \
		-e PACKAGECLOUD_TOKEN="$(PACKAGECLOUD_TOKEN)" \
		-v "$(mkfile_dir):/src" \
		-v "$(build_dir):/build" \
		-e PACKAGECLOUD_TOKEN="$(PACKAGECLOUD_TOKEN)" \
		-e AWS_ACCESS_KEY_ID="$(AWS_ACCESS_KEY_ID)" \
		-e AWS_SECRET_ACCESS_KEY="$(AWS_SECRET_ACCESS_KEY)" \
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
