#!/bin/sh -l
set -e

if [ "${INPUT_OTC_VERSION}" != "" ]; then
    export OTC_VERSION="${INPUT_OTC_VERSION}"
fi

if [ "${INPUT_OTC_SUMO_VERSION}" != "" ]; then
    export OTC_SUMO_VERSION="${INPUT_OTC_SUMO_VERSION}"
fi

if [ "${INPUT_OTC_BUILD_NUMBER}" != "" ]; then
    export OTC_BUILD_NUMBER="${INPUT_OTC_BUILD_NUMBER}"
fi

mkdir -p build
cd build || exit
$@
