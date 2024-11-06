#!/usr/bin/env bash

set -euxo pipefail

targetarch="$1"

GITHUB_CLI_VERSION="2.60.1"
PACKAGECLOUD_GO_VERSION="0.2.2"

# Convert between Docker CPU architecture names and other names such as Go's
# GOARCH.
if [ "$targetarch" = "amd64" ]; then
    GOARCH="amd64"
elif [ "$targetarch" = "arm64" ]; then
    GOARCH="arm64"
else
    GOARCH="amd64"
fi

function install_github_cli() {
    base_url="https://github.com/cli/cli/releases/download"
    version="${GITHUB_CLI_VERSION}"
    file="gh_${version}_linux_${GOARCH}.tar.gz"
    url="${base_url}/v${version}/${file}"

    # Download GitHub CLI
    curl -Lo /tmp/github-cli.tar.gz "${url}"

    # Verify that the file is gzip compressed data to prevent cases where
    # outages, site changes, etc. result in the downloaded file being HTML text.
    file /tmp/github-cli.tar.gz | grep "gzip compressed data"

    # Install GitHub CLI
    mkdir /tmp/github-cli
    tar -C /tmp/github-cli -zxf /tmp/github-cli.tar.gz --strip-components=1
    mv /tmp/github-cli/bin/gh /usr/local/bin/gh
}

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

install_github_cli
install_packagecloud_go
