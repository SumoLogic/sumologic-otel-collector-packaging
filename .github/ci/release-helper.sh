#!/usr/bin/env bash

set -euo pipefail

# Validate version format and discover workflow IDs for release orchestration
# Usage: release-helper.sh <package_version>

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "::error::Version parameter is required"
  exit 1
fi

# Validate version format: X.Y.Z-BUILD
if [[ ! "$VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)$ ]]; then
  echo "::error::Invalid version format. Expected: X.Y.Z-BUILD (e.g., 0.108.0-1790)"
  exit 1
fi

BUILD_NUMBER="${BASH_REMATCH[2]}"
echo "::notice::Validating version ${VERSION} (Build: ${BUILD_NUMBER})"

# Find packaging workflow by build number
PKG_RUN=$(gh run list -R SumoLogic/sumologic-otel-collector-packaging \
  -w build_packages.yml -s success -b main -L 200 \
  --json databaseId,displayTitle,number \
  -q ".[] | select(.number == ${BUILD_NUMBER}) | {id: .databaseId, title: .displayTitle}")

if [[ -z "$PKG_RUN" ]]; then
  echo "::error::Packaging workflow not found for build: ${BUILD_NUMBER}"
  exit 1
fi

PKG_ID=$(echo "$PKG_RUN" | jq -r '.id')
PKG_TITLE=$(echo "$PKG_RUN" | jq -r '.title')
echo "packaging-workflow-id=${PKG_ID}" >> "$GITHUB_OUTPUT"

# Extract collector workflow ID from packaging title
COLLECTOR_ID=$(echo "$PKG_TITLE" | sed -E 's/.*Build for Remote Workflow: ([0-9]+).*/\1/')

if [[ -z "$COLLECTOR_ID" ]]; then
  echo "::error::Could not extract collector workflow ID from: ${PKG_TITLE}"
  exit 1
fi

echo "collector-workflow-id=${COLLECTOR_ID}" >> "$GITHUB_OUTPUT"

# Verify collector workflow is successful
COLLECTOR_STATUS=$(gh run view "${COLLECTOR_ID}" -R SumoLogic/sumologic-otel-collector \
  --json status,conclusion -q '{status: .status, conclusion: .conclusion}')

STATUS=$(echo "$COLLECTOR_STATUS" | jq -r '.status')
CONCLUSION=$(echo "$COLLECTOR_STATUS" | jq -r '.conclusion')

if [[ "$STATUS" != "completed" ]] || [[ "$CONCLUSION" != "success" ]]; then
  echo "::error::Collector workflow ${COLLECTOR_ID} not successful (status: ${STATUS}, conclusion: ${CONCLUSION})"
  exit 1
fi

# Find containers workflow by collector ID
CONTAINERS_ID=$(gh run list -R SumoLogic/sumologic-otel-collector-containers \
  -w build-and-push.yml -s success -b main -L 200 \
  --json databaseId,displayTitle \
  -q ".[] | select(.displayTitle | contains(\"${COLLECTOR_ID}\")) | .databaseId" | head -n1)

if [[ -z "$CONTAINERS_ID" ]]; then
  echo "::error::Containers workflow not found for collector: ${COLLECTOR_ID}"
  exit 1
fi

echo "containers-workflow-id=${CONTAINERS_ID}" >> "$GITHUB_OUTPUT"

# Get collector version from artifacts
TEMP_DIR=$(mktemp -d)
if gh run download "${PKG_ID}" -R SumoLogic/sumologic-otel-collector-packaging \
   -n "otc-version.txt" -n "otc-sumo-version.txt" -D "$TEMP_DIR" 2>/dev/null; then
  OTC_VERSION=$(cat "$TEMP_DIR/otc-version.txt/otc-version.txt")
  OTC_SUMO=$(cat "$TEMP_DIR/otc-sumo-version.txt/otc-sumo-version.txt")
  COLLECTOR_VERSION="${OTC_VERSION}-sumo-${OTC_SUMO}"
  echo "collector-version=${COLLECTOR_VERSION}" >> "$GITHUB_OUTPUT"
  rm -rf "$TEMP_DIR"
fi

echo "::notice::✓ Discovered workflows - Collector: ${COLLECTOR_ID}, Packaging: ${PKG_ID}, Containers: ${CONTAINERS_ID}"
