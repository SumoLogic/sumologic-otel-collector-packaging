#!/bin/sh -l
set -e

if [ "${INPUT_OTC_VERSION}" != "" ]; then
    export OTC_VERSION="$(echo $INPUT_OTC_VERSION | xargs)"
fi

if [ "${INPUT_OTC_SUMO_VERSION}" != "" ]; then
    export OTC_SUMO_VERSION="$(echo $INPUT_OTC_SUMO_VERSION | xargs)"
fi

if [ "${INPUT_OTC_BUILD_NUMBER}" != "" ]; then
    export OTC_BUILD_NUMBER="$(echo $INPUT_OTC_BUILD_NUMBER | xargs)"
fi

if [ "${INPUT_WORKFLOW_ID}" != "" ]; then
    export OTC_ARTIFACTS_SOURCE="github-artifacts"
fi

mkdir -p build
cd build || exit
$@
