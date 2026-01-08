#!/usr/bin/env bash

set -euo pipefail

# Validate version format and discover workflow IDs for CI to RC promotion
# Usage: ci-to-rc-helper.sh <package_version>

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "::error::Version parameter is required"
  exit 1
fi

# Validate version format: X.Y.Z-BUILD
if [[ ! "$VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)-([0-9]+)$ ]]; then
  echo "::error::Invalid version format. Expected: X.Y.Z-BUILD (e.g., 0.124.0-2054)"
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

echo "::notice::✓ Discovered workflows - Packaging: ${PKG_ID}, Containers: ${CONTAINERS_ID} (Collector: ${COLLECTOR_ID})"
