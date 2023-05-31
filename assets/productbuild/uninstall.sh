#!/usr/bin/env bash

# exit when any command fails
set -e

expected_error=0

function on_exit() {
  cmd="$1"
  rc="$2"
  lineno="$3"

  if [ "$rc" -ne "0" ] && [ "$expected_error" -ne "1" ]; then
    echo "\"${cmd}\" command failed with exit code $rc on line ${lineno}"
  fi
}

# show the command that failed when the script exits unexpectedly
trap 'on_exit "$BASH_COMMAND" "$?" "$LINENO"' EXIT

# verify the script is being run as root
id="$(id -u)"
if [ "$id" -ne "0" ]
then
  echo "Must be run as root to run this script"
  expected_error=1
  exit 1
fi

# NOTE: The files in the lists below are removed in order. Directories are
# recursively removed but this will likely change in the future.

# TODO: Only remove empty directories by default to prevent additional files,
# such as config and state, from being removed. Then implement a purge option or
# similar to enable recursive directory removal.

# Collector service plist file
service_plist_file="/Library/LaunchDaemons/com.sumologic.otelcol-sumo.plist"

# A list of files & directories to remove for the collector
collector_files=(
  "/Library/LaunchDaemons/com.sumologic.otelcol-sumo.plist"
  "/etc/otelcol-sumo/sumologic.yaml"
  "/etc/otelcol-sumo/conf.d"
  "/etc/otelcol-sumo"
  "/usr/local/bin/otelcol-sumo"
  "/var/lib/otelcol-sumo/file_storage"
  "/var/lib/otelcol-sumo"
  "/var/log/otelcol-sumo"
)

# A list of files & directories to remove for hostmetrics
hostmetrics_files=(
  "/etc/otelcol-sumo/conf.d/hostmetrics.yaml"
)

function package_is_registered() {
  package_id="$1"
  pkgutil --pkg-info "$package_id"
  RC="$?"
  if [ "$RC" -ne "0" ]; then
    return 0
  fi
  return 1
}

function remove_file() {
  file="$1"

  if [ ! -e "$file" ]; then
    echo "Not found: ${file}"
    return
  fi

  if [ -f "$file" ]; then
    rm "$file"
    echo "File removed: ${file}"
  elif [ -d "$file" ]; then
    rm -r "$file"
    echo "Directory removed: ${file}"
  else
    echo "Error: Not a file or a directory: ${file}"
    exit 1
  fi
}

function stop_service() {
  plist_file="$1"

  echo "Stopping service: ${plist_file}"

  launchctl unload "${plist_file}"
}

function uninstall_package() {
  package_id="$1"
  package_files=("$@")

  echo "Uninstalling ${package_id}"

  for file in "${package_files[@]}"; do
    remove_file "$file"
  done

  if package_is_registered "${package_id}"; then
    echo "${package_id} is not registered, skipping unregistration"
    return
  fi

  pkgutil --forget "${package_id}"
}

stop_service "${service_plist_file}"
uninstall_package "com.sumologic.otelcol-sumo" "${collector_files[@]}"
uninstall_package "com.sumologic.otelcol-sumo-hostmetrics" "${hostmetrics_files[@]}"

# remove the directory that this script belongs to
SCRIPT_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
rm -rf "$SCRIPT_DIR"
