#!/bin/sh -l
set -e

if [ "${INPUT_OTC_VERSION}" != "" ]; then
    OTC_VERSION="$(echo "$INPUT_OTC_VERSION" | xargs)"
    export OTC_VERSION
fi

if [ "${INPUT_OTC_SUMO_VERSION}" != "" ]; then
    OTC_SUMO_VERSION="$(echo "$INPUT_OTC_SUMO_VERSION" | xargs)"
    export OTC_SUMO_VERSION
fi

if [ "${INPUT_OTC_BUILD_NUMBER}" != "" ]; then
    OTC_BUILD_NUMBER="$(echo "$INPUT_OTC_BUILD_NUMBER" | xargs)"
    export OTC_BUILD_NUMBER
fi

if [ "${INPUT_WORKFLOW_ID}" != "" ]; then
    export OTC_ARTIFACTS_SOURCE="github-artifacts"
fi

mkdir -p build
cd build || exit

# shellcheck disable=SC2068
$@
