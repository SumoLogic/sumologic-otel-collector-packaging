#!/bin/bash

set -eo pipefail

# Detects the latest release version for a GitHub project, parses it and echoes
# either OTC_VERSION or OTC_SUMO_VERSION depending on which is requested.

usage()
{
    echo "Usage: get_latest_release_version.sh [otc_version|otc_sumo_version]"
    exit 1
}

declare -i major_version
declare -i minor_version
declare -i patch_version
declare -i sumo_version
declare ot_channel
declare -i ot_channel_version
declare sumo_channel
declare -i sumo_channel_version


if [ "$#" -ne 1 ]
then
    usage
fi

case "$1" in
    otc_version|otc_sumo_version) ;;
    *)
        usage ;;
esac

# If VERSION_TAG environment variable isn't set then attempt to fetch the latest
# tag from GitHub Releases
if [ -z "$VERSION_TAG" ]; then
    REPO_ORG="${REPO_ORG:-SumoLogic}"
    REPO_PROJECT="${REPO_PROJECT:-sumologic-otel-collector}"

    api_url="https://api.github.com/repos/${REPO_ORG}/${REPO_PROJECT}/releases/latest"

    version_tag="$(curl -sLo- "${api_url}" | jq -r '.name' )"
else
    version_tag="$VERSION_TAG"
fi

version_regex="^v([0-9]+).([0-9]+).([0-9]+)((-(alpha|beta|rc|sumo)[-.]([0-9]+))(-(alpha|beta|rc).([0-9])+)?)?$"

if [[ $version_tag =~ $version_regex ]]; then
    major_version="${BASH_REMATCH[1]}"
    minor_version="${BASH_REMATCH[2]}"
    patch_version="${BASH_REMATCH[3]}"
    ot_channel="${BASH_REMATCH[6]}"
    ot_channel_version="${BASH_REMATCH[7]}"
    sumo_channel="${BASH_REMATCH[9]}"
    sumo_channel_version="${BASH_REMATCH[10]}"
else
    echo "Error: Cannot parse version information from tag: ${version_tag}" >&2
    exit 1
fi

if [[ $ot_channel == "sumo" ]]; then
    if [[ $sumo_channel != "" ]]; then
        sumo_version="${sumo_channel_version}"
    else
        sumo_version="${ot_channel_version}"
    fi
elif [[ $ot_channel != "" ]]; then
    sumo_version="${ot_channel_version}"
fi

case "$1" in
    otc_version)
        echo -n "${major_version}.${minor_version}.${patch_version}"
        ;;
    otc_sumo_version)
        echo -n "${sumo_version}"
        ;;
esac
