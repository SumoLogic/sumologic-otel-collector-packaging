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

# a list of system files that packages may use but should not be removed during
# uninstallation
system_files=(
  "etc"
  "Library"
  "Library/Application Support"
  "Library/LaunchDaemons"
  "usr"
  "usr/local"
  "usr/local/bin"
  "usr/local/share"
  "var"
  "var/lib"
  "var/log"
)

# a list of files that the collector package should install
expected_collector_files=(
  "etc/otelcol-sumo"
  "etc/otelcol-sumo/conf.d"
  "etc/otelcol-sumo/conf.d/common.yaml"
  "etc/otelcol-sumo/conf.d-available"
  "etc/otelcol-sumo/conf.d-available/ephemeral.yaml"
  "etc/otelcol-sumo/conf.d-available/hostmetrics.yaml"
  "etc/otelcol-sumo/conf.d-available/examples"
  "etc/otelcol-sumo/opamp.d"
  "etc/otelcol-sumo/opamp.d/.keep"
  "etc/otelcol-sumo/sumologic.yaml"
  "Library/Application Support/otelcol-sumo"
  "Library/Application Support/otelcol-sumo/uninstall.sh"
  "Library/LaunchDaemons/com.sumologic.otelcol-sumo.plist"
  "usr/local/bin/otelcol-config"
  "usr/local/bin/otelcol-sumo"
  "usr/local/share/otelcol-sumo"
  "usr/local/share/otelcol-sumo/otelcol-sumo.sh"
  "var/lib/otelcol-sumo"
  "var/lib/otelcol-sumo/file_storage"
  "var/log/otelcol-sumo"
)

function install_package() {
  mpkg="$1"
  mpkg_basename="$2"

  echo "################################################################################"
  echo "Installing package: ${mpkg}"
  echo "################################################################################"

  choices_xml="${tmp_dir}/${mpkg_basename}-choices.xml"

  # extract choices xml from meta package, override the choices to enable
  # optional choices, and then install using the new choice selections
  installer -showChoiceChangesXML -pkg "$mpkg" -target / > "$choices_xml"
  override_choices
  installer -applyChoiceChangesXML "$choices_xml" -pkg "$mpkg" -target /
}

function override_choices() {
  # determine how many installation choices exist
  count=$(plutil -convert raw -o - "$choices_xml")

  # loop through each installation choice
  for (( j=0; j < "$count"; j++ )); do
    choice_id_key="${j}.choiceIdentifier"
    choice_attr_key="${j}.choiceAttribute"
    attr_setting_key="${j}.attributeSetting"

    # skip if choiceAttribute does not equal selected
    choice_attr="$(plutil -extract "$choice_attr_key" raw -o - "$choices_xml")"
    if [ "$choice_attr" != "selected" ]; then
      continue
    fi

    # get the choice identifier
    choice_id="$(plutil -extract "$choice_id_key" raw -o - "$choices_xml")"

    # get the current value for the installation choice
    current_value="$(plutil -extract "$attr_setting_key" raw -o - "$choices_xml")"

    echo "Overriding selected attributeSetting ${choice_id}: $current_value -> 1"
    plutil -replace "$attr_setting_key" -integer 1 "$choices_xml"
  done
}

function verify_installation() {
  local pkg="$1"
  shift
  local expected_files=("$@")

  # verify package is registered
  pkgutil --pkg-info "$pkg"
  RC="$?"
  if [ "$RC" -ne "0" ]; then
    echo "Error: ${pkg} is not installed"
    expected_error=1
    exit 1
  fi

  for file in "${expected_files[@]}"; do
    target="/"
    file="${target}${file}"
    if [ ! -e "${file}" ]; then
      echo "Error: \"${file}\" from package \"${pkg}\" was expected but was not found"
      expected_error=1
      exit 1
    fi
  done
}

function verify_uninstallation() {
  local pkg_id="$1"
  shift
  local expected_files=("$@")

  # verify package is unregistered
  set +e
  pkgutil --pkg-info "$pkg_id"
  RC="$?"
  set -e
  if [ "$RC" -eq "0" ]; then
    echo "package is still registered: ${pkg_id}"
    expected_error=1
    exit 1
  fi

  for file in "${expected_files[@]}"; do
    target="/"
    file="${target}${file}"
    if [ -e "${file}" ]; then
      echo "Error: \"${file}\" from package \"${pkg_id}\" was not uninstalled"
      expected_error=1
      exit 1
    fi
  done
}

mpkg="$1"
mpkg_basename="$(basename "$mpkg")"
exec_dir="$(pwd)"
tmp_dir="$(mktemp -d)"

expanded_dir="${tmp_dir}/${mpkg_basename}"

pkgutil --expand-full "$mpkg" "$expanded_dir"

cd "$expanded_dir" || exit

# create an array of all packages
all_pkgs=()
while IFS=  read -r -d $'\0'; do
  all_pkgs+=("$REPLY")
done < <(find . -name "*.pkg" -type d -print0)

# create an array of collector packages (only one is expected)
collector_pkg=()
while IFS=  read -r -d $'\0'; do
  collector_pkg+=("$REPLY")
done < <(find . -name "*-otelcol-sumo.pkg" -type d -print0)

# verify that the expected number of sub-packages were found
pkg_count="${#all_pkgs[@]}"
expected_pkg_count=1

if [ "$pkg_count" -ne $expected_pkg_count ]; then
  echo "error: ${expected_pkg_count} sub-packages were expected but found ${pkg_count}"
  exit 1
fi

# only one collector sub-package should exist
if [ "${#collector_pkg[@]}" -gt 1 ]; then
  echo "error: more than one collector sub-package was found"
  exit 1
fi

# get a list of files installed by the collector sub-package excluding system
# files
collector_pkg_name="$(echo "${collector_pkg[0]}" | cut -d/ -f2-)"
cd "${collector_pkg_name}/Payload" || exit
all_collector_files=()
while IFS=  read -r -d $'\0'; do
  all_collector_files+=("$REPLY")
done < <(find . ! -name '.' -print0)

collector_files=()

for f in "${all_collector_files[@]}"; do
  collector_file="$(echo "$f" | cut -d/ -f2-)"

  # shellcheck disable=SC2076
  if [[ " ${system_files[*]} " =~ " ${collector_file} " ]]; then
    continue
  fi

  if [[ " $(dirname "${collector_file}") " == " etc/otelcol-sumo/conf.d-available/examples " ]]; then
    continue
  fi

  # shellcheck disable=SC2076
  if [[ ! " ${expected_collector_files[*]} " =~ " ${collector_file} " ]]; then
    echo "error: unexpected file installed by collector sub-package: ${collector_file}"
    exit 1
  fi

  collector_files+=("$collector_file")
done

cd "$exec_dir" || exit

install_package "$mpkg" "$mpkg_basename"

echo
echo "################################################################################"
echo "Verifying installation: ${mpkg}"
echo "################################################################################"
verify_installation "com.sumologic.otelcol-sumo" "${expected_collector_files[@]}"

echo
echo "################################################################################"
echo "Uninstalling package: ${mpkg}"
echo "################################################################################"
/Library/Application\ Support/otelcol-sumo/uninstall.sh
RC="$?"
if [ "$RC" -ne "0" ]; then
  echo "Error: Uninstallation failed"
  exit 1
fi

echo
echo "################################################################################"
echo "Verifying uninstallation: ${mpkg}"
echo "################################################################################"
verify_uninstallation "com.sumologic.otelcol-sumo" "${expected_collector_files[@]}"

echo "Success!"
