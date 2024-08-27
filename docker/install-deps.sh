#!/usr/bin/env bash

set -euxo pipefail

targetarch="$1"

PACKAGECLOUD_GO_VERSION="0.1.5"

# Convert between Docker CPU architecture names and other names such as Go's
# GOARCH.
if [ "$targetarch" = "amd64" ]; then
    GOARCH="amd64"
elif [ "$targetarch" = "arm64" ]; then
    GOARCH="arm64"
else
    GOARCH="amd64"
fi

function install_packagecloud_go() {
    base_url="https://github.com/amdprophet/packagecloud-go/releases/download"
    version="${PACKAGECLOUD_GO_VERSION}"
    file="packagecloud-go_${version}_linux_${GOARCH}.tar.gz"
    url="${base_url}/${version}/${file}"

    # Download packagecloud-go
    curl -Lo /tmp/packagecloud-go.tar.gz "${url}"

    # Verify that the file is gzip compressed data to prevent cases where
    # outages, site changes, etc. result in the downloaded file being HTML text.
    file /tmp/packagecloud-go.tar.gz | grep "gzip compressed data"

    # Install packagecloud-go
    tar -C /tmp -zxf /tmp/packagecloud-go.tar.gz
    mv /tmp/packagecloud /usr/local/bin/packagecloud
}

install_packagecloud_go
