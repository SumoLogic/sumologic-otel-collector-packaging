#!/bin/sh -l
set -e

if [ "${INPUT_OTC_BUILD_NUMBER}" != "" ]; then
    OTC_BUILD_NUMBER="$(echo "$INPUT_OTC_BUILD_NUMBER" | xargs)"
    export OTC_BUILD_NUMBER
fi

mkdir -p build

if [ -n "${WORK_DIR}" ]; then
    cd "${WORK_DIR}" || exit
else
    cd build || exit
fi

# shellcheck disable=SC2068
$@
