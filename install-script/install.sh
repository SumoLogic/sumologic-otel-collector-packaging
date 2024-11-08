#!/usr/bin/env bash

set -euo pipefail

############################ Static variables

ARG_SHORT_TOKEN='i'
ARG_LONG_TOKEN='installation-token'
DEPRECATED_ARG_LONG_TOKEN='installation-token'
ARG_SHORT_HELP='h'
ARG_LONG_HELP='help'
ARG_SHORT_API='a'
ARG_LONG_API='api'
ARG_SHORT_OPAMP_API='o'
ARG_LONG_OPAMP_API='opamp-api'
ARG_SHORT_TAG='t'
ARG_LONG_TAG='tag'
ARG_SHORT_VERSION='v'
ARG_LONG_VERSION='version'
ARG_SHORT_FIPS='f'
ARG_LONG_FIPS='fips'
ARG_SHORT_YES='y'
ARG_LONG_YES='yes'
ARG_SHORT_UNINSTALL='u'
ARG_LONG_UNINSTALL='uninstall'
ARG_SHORT_UPGRADE='g'
ARG_LONG_UPGRADE='upgrade'
ARG_SHORT_PURGE='p'
ARG_LONG_PURGE='purge'
ARG_SHORT_SKIP_TOKEN='k'
ARG_LONG_SKIP_TOKEN='skip-installation-token'
DEPRECATED_ARG_LONG_SKIP_TOKEN='skip-install-token'
ARG_SHORT_DOWNLOAD='w'
ARG_LONG_DOWNLOAD='download-only'
ARG_SHORT_CONFIG_BRANCH='c'
ARG_LONG_CONFIG_BRANCH='config-branch'
ARG_SHORT_BINARY_BRANCH='e'
ARG_LONG_BINARY_BRANCH='binary-branch'
ENV_TOKEN="SUMOLOGIC_INSTALLATION_TOKEN"
DEPRECATED_ENV_TOKEN="SUMOLOGIC_INSTALL_TOKEN"
ARG_SHORT_BRANCH='b'
ARG_LONG_BRANCH='branch'
ARG_SHORT_KEEP_DOWNLOADS='n'
ARG_LONG_KEEP_DOWNLOADS='keep-downloads'
ARG_SHORT_INSTALL_HOSTMETRICS='H'
ARG_LONG_INSTALL_HOSTMETRICS='install-hostmetrics'
ARG_SHORT_REMOTELY_MANAGED='r'
ARG_LONG_REMOTELY_MANAGED='remotely-managed'
ARG_SHORT_EPHEMERAL='E'
ARG_LONG_EPHEMERAL='ephemeral'
ARG_SHORT_TIMEOUT='m'
ARG_LONG_TIMEOUT='download-timeout'

readonly ARG_SHORT_TOKEN ARG_LONG_TOKEN ARG_SHORT_HELP ARG_LONG_HELP ARG_SHORT_API ARG_LONG_API
readonly ARG_SHORT_TAG ARG_LONG_TAG ARG_SHORT_VERSION ARG_LONG_VERSION ARG_SHORT_YES ARG_LONG_YES
readonly ARG_SHORT_UNINSTALL ARG_LONG_UNINSTALL
readonly ARG_SHORT_UPGRADE ARG_LONG_UPGRADE
readonly ARG_SHORT_PURGE ARG_LONG_PURGE ARG_SHORT_DOWNLOAD ARG_LONG_DOWNLOAD
readonly ARG_SHORT_CONFIG_BRANCH ARG_LONG_CONFIG_BRANCH ARG_SHORT_BINARY_BRANCH ARG_LONG_CONFIG_BRANCH
readonly ARG_SHORT_BRANCH ARG_LONG_BRANCH
readonly ARG_SHORT_SKIP_TOKEN ARG_LONG_SKIP_TOKEN ARG_SHORT_FIPS ARG_LONG_FIPS ENV_TOKEN
readonly ARG_SHORT_INSTALL_HOSTMETRICS ARG_LONG_INSTALL_HOSTMETRICS
readonly ARG_SHORT_REMOTELY_MANAGED ARG_LONG_REMOTELY_MANAGED
readonly ARG_SHORT_EPHEMERAL ARG_LONG_EPHEMERAL
readonly ARG_SHORT_TIMEOUT ARG_LONG_TIMEOUT
readonly DEPRECATED_ARG_LONG_TOKEN DEPRECATED_ENV_TOKEN DEPRECATED_ARG_LONG_SKIP_TOKEN

############################ Variables (see set_defaults function for default values)

# Support providing installation_token as env
set +u
if [[ -z "${SUMOLOGIC_INSTALLATION_TOKEN}" && -z "${SUMOLOGIC_INSTALL_TOKEN}" ]]; then
    SUMOLOGIC_INSTALLATION_TOKEN=""
elif [[ -z "${SUMOLOGIC_INSTALLATION_TOKEN}" ]]; then
    echo "${DEPRECATED_ENV_TOKEN} environmental variable is deprecated. Please use ${ENV_TOKEN} instead."
    SUMOLOGIC_INSTALLATION_TOKEN="${SUMOLOGIC_INSTALL_TOKEN}"
fi
set -u

API_BASE_URL=""
OPAMP_API_URL=""
FIELDS=()
VERSION=""
FIPS=false
CONTINUE=false
CONFIG_DIRECTORY=""
USER_ENV_DIRECTORY=""
UNINSTALL=""
UPGRADE=""
SUMO_BINARY_PATH=""
SUMO_CONFIG_BINARY_PATH=""
COMMON_CONFIG_PATH=""
PURGE=""
DOWNLOAD_ONLY=""
INSTALL_HOSTMETRICS=false
REMOTELY_MANAGED=false
EPHEMERAL=false

LAUNCHD_CONFIG=""
LAUNCHD_ENV_KEY=""
LAUNCHD_TOKEN_KEY=""

USER_API_URL=""
USER_OPAMP_API_URL=""
USER_TOKEN=""

CONFIG_BRANCH=""
BINARY_BRANCH=""

KEEP_DOWNLOADS=false

CURL_MAX_TIME=1800

# NB: the S3 variables are only used on Darwin
S3_BUCKET="${S3_BUCKET:-sumologic-osc-stable}"
S3_REGION="${S3_REGION:-us-west-2}"
S3_URI="https://${S3_BUCKET}.s3.${S3_REGION}.amazonaws.com"

PACKAGECLOUD_ORG="${PACKAGECLOUD_ORG:-sumologic}"
PACKAGECLOUD_REPO="${PACKAGECLOUD_REPO:-stable}"
PACKAGECLOUD_MASTER_TOKEN="${PACKAGECLOUD_MASTER_TOKEN:-}"

############################ Functions

function usage() {
  cat << EOF

Usage: bash install.sh [--${ARG_LONG_TOKEN} <token>] [--${ARG_LONG_TAG} <key>=<value> [ --${ARG_LONG_TAG} ...]] [--${ARG_LONG_API} <url>] [--${ARG_LONG_OPAMP_API} <url>] [--${ARG_LONG_VERSION} <version>] \\
                       [--${ARG_LONG_YES}] [--${ARG_LONG_VERSION} <version>] [--${ARG_LONG_HELP}]

Supported arguments:
  -${ARG_SHORT_TOKEN}, --${ARG_LONG_TOKEN} <token>      Installation token. It has precedence over 'SUMOLOGIC_INSTALLATION_TOKEN' env variable.
  -${ARG_SHORT_SKIP_TOKEN}, --${ARG_LONG_SKIP_TOKEN}         Skips requirement for installation token.
                                        This option do not disable default configuration creation.
  -${ARG_SHORT_TAG}, --${ARG_LONG_TAG} <key=value>                 Sets tag for collector. This argument can be use multiple times. One per tag.
  -${ARG_SHORT_DOWNLOAD}, --${ARG_LONG_DOWNLOAD}                   Download new binary only and skip configuration part. (Mac OS only)

  -${ARG_SHORT_UPGRADE}, --${ARG_LONG_UPGRADE}                     Upgrades the collector using the system package manager.
  -${ARG_SHORT_UNINSTALL}, --${ARG_LONG_UNINSTALL}                       Removes Sumo Logic Distribution for OpenTelemetry Collector from the system and
                                        disable Systemd service eventually.
                                        Use with '--purge' to remove all configurations as well.
  -${ARG_SHORT_PURGE}, --${ARG_LONG_PURGE}                           It has to be used with '--${ARG_LONG_UNINSTALL}'.
                                        It removes all Sumo Logic Distribution for OpenTelemetry Collector related configuration and data.

  -${ARG_SHORT_API}, --${ARG_LONG_API} <url>                       API URL, forces the collector to use non-default API
  -${ARG_SHORT_OPAMP_API}, --${ARG_LONG_OPAMP_API} <url>            OpAmp API URL, forces the collector to use non-default OpAmp API
  -${ARG_SHORT_VERSION}, --${ARG_LONG_VERSION} <version>               Version of Sumo Logic Distribution for OpenTelemetry Collector to install, e.g. 0.57.2-sumo-1.
                                        By default it gets latest version.
  -${ARG_SHORT_FIPS}, --${ARG_LONG_FIPS}                            Install the FIPS 140-2 compliant binary on Linux.
  -${ARG_SHORT_INSTALL_HOSTMETRICS}, --${ARG_LONG_INSTALL_HOSTMETRICS}             Install the hostmetrics configuration to collect host metrics.
  -${ARG_SHORT_REMOTELY_MANAGED}, --${ARG_LONG_REMOTELY_MANAGED}                Remotely manage the collector configuration with Sumo Logic.
  -${ARG_SHORT_EPHEMERAL}, --${ARG_LONG_EPHEMERAL}                       Delete the collector from Sumo Logic after 12 hours of inactivity.
  -${ARG_SHORT_TIMEOUT}, --${ARG_LONG_TIMEOUT} <timeout>      Timeout in seconds after which download will fail. Default is ${CURL_MAX_TIME}.
  -${ARG_SHORT_YES}, --${ARG_LONG_YES}                             Disable confirmation asks.

  -${ARG_SHORT_HELP}, --${ARG_LONG_HELP}                            Prints this help and usage.

Supported env variables:
  ${ENV_TOKEN}=<token>       Installation token.'
EOF
}

function set_defaults() {
    DOWNLOAD_CACHE_DIR="/var/cache/otelcol-sumo"  # this is in case we want to keep downloaded binaries
    CONFIG_DIRECTORY="/etc/otelcol-sumo"
    SUMO_BINARY_PATH="/usr/local/bin/otelcol-sumo"
    SUMO_CONFIG_BINARY_PATH="/usr/local/bin/otelcol-config"
    USER_ENV_DIRECTORY="${CONFIG_DIRECTORY}/env"
    TOKEN_ENV_FILE="${USER_ENV_DIRECTORY}/token.env"

    LAUNCHD_CONFIG="/Library/LaunchDaemons/com.sumologic.otelcol-sumo.plist"
    LAUNCHD_ENV_KEY="EnvironmentVariables"
    LAUNCHD_TOKEN_KEY="${LAUNCHD_ENV_KEY}.${ENV_TOKEN}"

    # ensure the cache dir exists
    mkdir -p "${DOWNLOAD_CACHE_DIR}"
}

function parse_options() {
  # Transform long options to short ones
  for arg in "$@"; do

    shift
    case "$arg" in
      "--${ARG_LONG_HELP}")
        set -- "$@" "-${ARG_SHORT_HELP}"
        ;;
      "--${ARG_LONG_TOKEN}")
        set -- "$@" "-${ARG_SHORT_TOKEN}"
        ;;
      "--${DEPRECATED_ARG_LONG_TOKEN}")
        echo "--${DEPRECATED_ARG_LONG_TOKEN}" is deprecated. Please use "--${ARG_LONG_TOKEN}" instead.
        set -- "$@" "-${ARG_SHORT_TOKEN}"
        ;;
      "--${ARG_LONG_OPAMP_API}")
        set -- "$@" "-${ARG_SHORT_OPAMP_API}"
        ;;
      "--${ARG_LONG_API}")
        set -- "$@" "-${ARG_SHORT_API}"
        ;;
      "--${ARG_LONG_TAG}")
        set -- "$@" "-${ARG_SHORT_TAG}"
        ;;
      "--${ARG_LONG_YES}")
        set -- "$@" "-${ARG_SHORT_YES}"
        ;;
      "--${ARG_LONG_VERSION}")
        set -- "$@" "-${ARG_SHORT_VERSION}"
        ;;
      "--${ARG_LONG_FIPS}")
        set -- "$@" "-${ARG_SHORT_FIPS}"
        ;;
      "--${ARG_LONG_UNINSTALL}")
        set -- "$@" "-${ARG_SHORT_UNINSTALL}"
        ;;
      "--${ARG_LONG_UPGRADE}")
        set -- "$@" "-${ARG_SHORT_UPGRADE}"
        ;;
      "--${ARG_LONG_PURGE}")
        set -- "$@" "-${ARG_SHORT_PURGE}"
        ;;
      "--${ARG_LONG_SKIP_TOKEN}")
        echo "--${ARG_LONG_SKIP_TOKEN}" is deprecated and no longer affects the installation. An installation token is required.
        set -- "$@" "-${ARG_SHORT_SKIP_TOKEN}"
        ;;
      "--${DEPRECATED_ARG_LONG_SKIP_TOKEN}")
        echo "--${DEPRECATED_ARG_LONG_SKIP_TOKEN}" is deprecated. Please use "--${ARG_SHORT_SKIP_TOKEN}" instead.
        set -- "$@" "-${ARG_SHORT_SKIP_TOKEN}"
        ;;
      "--${ARG_LONG_DOWNLOAD}")
        set -- "$@" "-${ARG_SHORT_DOWNLOAD}"
        ;;
      "--${ARG_LONG_BRANCH}")
        set -- "$@" "-${ARG_SHORT_BRANCH}"
        ;;
      "--${ARG_LONG_BINARY_BRANCH}")
        set -- "$@" "-${ARG_SHORT_BINARY_BRANCH}"
        ;;
      "--${ARG_LONG_CONFIG_BRANCH}")
        set -- "$@" "-${ARG_SHORT_CONFIG_BRANCH}"
        ;;
      "--${ARG_LONG_KEEP_DOWNLOADS}")
        set -- "$@" "-${ARG_SHORT_KEEP_DOWNLOADS}"
        ;;
      "--${ARG_LONG_TIMEOUT}")
        set -- "$@" "-${ARG_SHORT_TIMEOUT}"
        ;;
      "-${ARG_SHORT_TOKEN}"|"-${ARG_SHORT_HELP}"|"-${ARG_SHORT_API}"|"-${ARG_SHORT_OPAMP_API}"|"-${ARG_SHORT_TAG}"|"-${ARG_SHORT_VERSION}"|"-${ARG_SHORT_FIPS}"|"-${ARG_SHORT_YES}"|"-${ARG_SHORT_UNINSTALL}"|"-${ARG_SHORT_UPGRADE}"|"-${ARG_SHORT_PURGE}"|"-${ARG_SHORT_SKIP_TOKEN}"|"-${ARG_SHORT_DOWNLOAD}"|"-${ARG_SHORT_CONFIG_BRANCH}"|"-${ARG_SHORT_BINARY_BRANCH}"|"-${ARG_SHORT_BRANCH}"|"-${ARG_SHORT_KEEP_DOWNLOADS}"|"-${ARG_SHORT_TIMEOUT}"|"-${ARG_SHORT_INSTALL_HOSTMETRICS}"|"-${ARG_SHORT_REMOTELY_MANAGED}"|"-${ARG_SHORT_EPHEMERAL}")
        set -- "$@" "${arg}"
        ;;
      "--${ARG_LONG_INSTALL_HOSTMETRICS}")
        set -- "$@" "-${ARG_SHORT_INSTALL_HOSTMETRICS}"
        ;;
      "--${ARG_LONG_REMOTELY_MANAGED}")
        set -- "$@" "-${ARG_SHORT_REMOTELY_MANAGED}"
        ;;
      "--${ARG_LONG_EPHEMERAL}")
        set -- "$@" "-${ARG_SHORT_EPHEMERAL}"
        ;;
      -*)
        echo "Unknown option ${arg}"; usage; exit 2 ;;
      *)
        set -- "$@" "$arg" ;;
    esac
  done

  # Parse short options
  OPTIND=1

  while true; do
    set +e
    getopts "${ARG_SHORT_HELP}${ARG_SHORT_TOKEN}:${ARG_SHORT_API}:${ARG_SHORT_OPAMP_API}:${ARG_SHORT_TAG}:${ARG_SHORT_VERSION}:${ARG_SHORT_FIPS}${ARG_SHORT_YES}${ARG_SHORT_UPGRADE}${ARG_SHORT_UNINSTALL}${ARG_SHORT_PURGE}${ARG_SHORT_SKIP_TOKEN}${ARG_SHORT_DOWNLOAD}${ARG_SHORT_KEEP_DOWNLOADS}${ARG_SHORT_CONFIG_BRANCH}:${ARG_SHORT_BINARY_BRANCH}:${ARG_SHORT_BRANCH}:${ARG_SHORT_EPHEMERAL}${ARG_SHORT_REMOTELY_MANAGED}${ARG_SHORT_INSTALL_HOSTMETRICS}${ARG_SHORT_TIMEOUT}:" opt
    set -e

    # Invalid argument catched, print and exit
    if [[ $? != 0 && ${OPTIND} -le $# ]]; then
      echo "Invalid argument:" "${@:${OPTIND}:1}"
      usage
      exit 2
    fi

    # Validate opt and set arguments
    case "$opt" in
      "${ARG_SHORT_HELP}")          usage; exit 0 ;;
      "${ARG_SHORT_TOKEN}")         SUMOLOGIC_INSTALLATION_TOKEN="${OPTARG}" ;;
      "${ARG_SHORT_API}")           API_BASE_URL="${OPTARG}" ;;
      "${ARG_SHORT_OPAMP_API}")     OPAMP_API_URL="${OPTARG}" ;;
      "${ARG_SHORT_VERSION}")       VERSION="${OPTARG}" ;;
      "${ARG_SHORT_FIPS}")          FIPS=true ;;
      "${ARG_SHORT_YES}")           CONTINUE=true ;;
      "${ARG_SHORT_UNINSTALL}")     UNINSTALL=true ;;
      "${ARG_SHORT_UPGRADE}")       UPGRADE=true ;;
      "${ARG_SHORT_PURGE}")         PURGE=true ;;
      "${ARG_SHORT_DOWNLOAD}")      DOWNLOAD_ONLY=true ;;
      "${ARG_SHORT_CONFIG_BRANCH}") CONFIG_BRANCH="${OPTARG}" ;;
      "${ARG_SHORT_BINARY_BRANCH}") BINARY_BRANCH="${OPTARG}" ;;
      "${ARG_SHORT_BRANCH}")
        if [[ -z "${BINARY_BRANCH}" ]]; then
            BINARY_BRANCH="${OPTARG}"
        fi
        if [[ -z "${CONFIG_BRANCH}" ]]; then
            CONFIG_BRANCH="${OPTARG}"
        fi ;;
      "${ARG_SHORT_INSTALL_HOSTMETRICS}") INSTALL_HOSTMETRICS=true ;;
      "${ARG_SHORT_REMOTELY_MANAGED}") REMOTELY_MANAGED=true ;;
      "${ARG_SHORT_EPHEMERAL}") EPHEMERAL=true ;;
      "${ARG_SHORT_KEEP_DOWNLOADS}") KEEP_DOWNLOADS=true ;;
      "${ARG_SHORT_TIMEOUT}") CURL_MAX_TIME="${OPTARG}" ;;
      "${ARG_SHORT_TAG}") FIELDS+=("${OPTARG}") ;;
    esac

    # Exit loop as we iterated over all arguments
    if [[ "${OPTIND}" -gt $# ]]; then
      break
    fi
  done
}

# Ensure TMPDIR is set to a directory where we can safely store temporary files
function set_tmpdir() {
    # generate a new tmpdir using mktemp
    # need to specify the template for some MacOS versions
    TMPDIR=$(mktemp -d -t 'sumologic-otel-collector-XXXX')
}

function check_dependencies() {
    local error
    error=0

    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root."
        error=1
    fi

    REQUIRED_COMMANDS=(echo sed curl head grep sort mv getopts hostname touch xargs)
    if [[ -n "${BINARY_BRANCH}" ]]; then  # unzip is only necessary for downloading from GHA artifacts
        REQUIRED_COMMANDS+=(unzip)
    fi

    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "${cmd}" &> /dev/null; then
            echo "Command '${cmd}' not found. Please install it."
            error=1
        fi
    done

    if [[ "${error}" == "1" ]] ; then
        exit 1
    fi
}

# NB: this function is only for Darwin
function get_latest_s3_package_version() {
    curl --retry 5 --connect-timeout 5 --max-time 30 --retry-delay 0 \
        --retry-max-time 150 -s \
        "${S3_URI}/latest_version" | tr -d '\n'
}

# Get OS type (linux or darwin)
function get_os_type() {
    local os_type
    # Detect OS using uname
    case "$(uname)" in
    Darwin)
        os_type=darwin
        ;;
    Linux)
        os_type=linux
        ;;
    *)
        echo -e "Unsupported OS type:\t$(uname)"
        exit 1
        ;;
    esac
    echo "${os_type}"
}

# Get arch type (amd64 or arm64)
function get_arch_type() {
    local arch_type
    case "$(uname -m)" in
    x86_64)
        arch_type=amd64
        ;;
    aarch64_be | aarch64 | armv8b | armv8l | arm64)
        arch_type=arm64
        ;;
    *)
        echo -e "Unsupported architecture type:\t$(uname -m)"
        exit 1
        ;;
    esac
    echo "${arch_type}"
}

# Verify that the otelcol install is correct
function verify_installation() {
    local otel_command
    if command -v otelcol-sumo; then
        otel_command="otelcol-sumo"
    else
        echo "WARNING: ${SUMO_BINARY_PATH} is not in \$PATH"
        otel_command="${SUMO_BINARY_PATH}"
    fi
    if ! command -v otelcol-config; then
        echo "WARNING: ${SUMO_CONFIG_BINARY_PATH} is not in \$PATH"
    fi
    echo "Running ${otel_command} --version to verify installation"
    OUTPUT="$(${otel_command} --version || true)"
    readonly OUTPUT

    if [[ -z "${OUTPUT}" ]]; then
        echo "Installation failed. Please try again"
        exit 1
    fi

    echo -e "Installation succeded:\t$(${otel_command} --version)"
}

# Ask to continue and abort if not
function ask_to_continue() {
    if [[ "${CONTINUE}" == true ]]; then
        return 0
    fi

    # Just fail if we're not running in uninteractive mode
    # TODO: Figure out a way to reliably ask for confirmation with stdin redirected

    echo "Please use the -y flag to continue"
    exit 1

    # local choice
    # read -rp "Continue (y/N)? " choice
    # case "${choice}" in
    # y|Y ) ;;
    # n|N | * )
    #     echo "Aborting..."
    #     exit 1
    #     ;;
    # esac

}

# set up configuration
function setup_config() {
    echo 'We are going to get and set up a default configuration for you'

    echo "Generating configuration and saving it in ${CONFIG_DIRECTORY}"
    if [[ "${REMOTELY_MANAGED}" == "true" ]]; then
        echo "Warning: remote management is currently in beta."

        write_opamp_extension

        if [[ -n "${SUMOLOGIC_INSTALLATION_TOKEN}" ]]; then
            write_installation_token "${SUMOLOGIC_INSTALLATION_TOKEN}"
        fi

        if [[ "${EPHEMERAL}" == "true" ]]; then
            write_ephemeral_true
        fi

        if [[ -n "${API_BASE_URL}" ]]; then
            write_api_url "${API_BASE_URL}"
        fi

        if [[ -n "${OPAMP_API_URL}" ]]; then
            write_opamp_endpoint "${OPAMP_API_URL}"
        fi

        if [[ ${#FIELDS[@]} -gt 0 ]]; then
            write_tags "${FIELDS[@]}"
        fi

        # Return/stop function execution early as remaining logic only applies
        # to locally-managed installations
        return
    fi

    if [[ "${INSTALL_HOSTMETRICS}" == "true" ]]; then
        echo -e "Installing ${OS_TYPE} hostmetrics configuration"
        "${SUMO_CONFIG_BINARY_PATH}" --enable-hostmetrics
    fi

    ## Check if there is anything to update in configuration
    if [[ -n "${SUMOLOGIC_INSTALLATION_TOKEN}" || -n "${API_BASE_URL}" || ${#FIELDS[@]} -ne 0 || "${EPHEMERAL}" == "true" ]]; then
        USER_TOKEN="$(get_user_token)"

        if [[ -n "${SUMOLOGIC_INSTALLATION_TOKEN}" && -z "${USER_TOKEN}" ]]; then
            write_installation_token "${SUMOLOGIC_INSTALLATION_TOKEN}"
        fi

        if [[ "${EPHEMERAL}" == "true" ]]; then
            write_ephemeral_true
        fi

        if [[ -n "${API_BASE_URL}" && -z "${USER_API_URL}" ]]; then
            write_api_url "${API_BASE_URL}"
        fi

        if [[ ${#FIELDS[@]} -gt 0 ]]; then
            write_tags "${FIELDS[@]}"
        fi
    fi
}

function setup_config_darwin() {
    echo 'We are going to get and set up a default configuration for you'

    echo "Generating configuration and saving it in ${CONFIG_DIRECTORY}"
    if [[ "${REMOTELY_MANAGED}" == "true" ]]; then
        echo "Warning: remote management is currently in beta."

        write_opamp_extension

        if [[ -n "${OPAMP_API_URL}" ]]; then
            write_opamp_endpoint "${OPAMP_API_URL}"
        fi
    fi

    if [[ "${EPHEMERAL}" == "true" ]]; then
        write_ephemeral_true
    fi

    if [[ -n "${API_BASE_URL}"  ]]; then
        write_api_url "${API_BASE_URL}"
    elif [[ -n "${USER_API_URL}" ]]; then
        write_api_url "${USER_API_URL}"
    fi

    if [[ ${#FIELDS[@]} -gt 0 ]]; then
        write_tags "${FIELDS[@]}"
    fi

    # Return/stop function execution early as remaining logic only applies to
    # locally-managed installations
    if [[ "${REMOTELY_MANAGED}" == "true" ]]; then
        return
    fi

    if [[ "${INSTALL_HOSTMETRICS}" == "true" ]]; then
        echo -e "Installing ${OS_TYPE} hostmetrics configuration"
        "${SUMO_CONFIG_BINARY_PATH}" --enable-hostmetrics
    fi
}

# uninstall otelcol-sumo
function uninstall() {
    case "${OS_TYPE}" in
    "darwin") uninstall_darwin ;;
    "linux") uninstall_linux ;;
    *)
      echo "Uninstallation is not supported by this script for OS: ${OS_TYPE}"
      exit 1
      ;;
    esac

    echo "Uninstallation completed"
}

function upgrade() {
    case "${OS_TYPE}" in
    "linux") upgrade_linux ;;
    *)
      echo "upgrading is not supported by this script for OS: ${OS_TYPE}"
      exit 1
      ;;
    esac

}

function upgrade_linux() {
    case $(get_package_manager) in
        yum | dnf)
            yum update otelcol-sumo --quiet -y
            ;;
        apt-get)
            apt-get update --quiet && apt-get upgrade otelcol-sumo --quiet -y
            ;;
    esac
}

# uninstall otelcol-sumo on darwin
function uninstall_darwin() {
    local UNINSTALL_SCRIPT_PATH
    UNINSTALL_SCRIPT_PATH="/Library/Application Support/otelcol-sumo/uninstall.sh"

    echo "Going to uninstall otelcol-sumo."

    if [[ "${PURGE}" == "true" ]]; then
        echo "WARNING: purge is not yet supported on darwin"
    fi

    ask_to_continue

    "${UNINSTALL_SCRIPT_PATH}"
}

# uninstall otelcol-sumo on linux
function uninstall_linux() {
    case $(get_package_manager) in
        yum | dnf)
            yum remove --quiet -y otelcol-sumo
            ;;
        apt-get)
            if [[ "${PURGE}" == "true" ]]; then
                apt-get purge --quiet -y otelcol-sumo
            else
                apt-get remove --quiet -y otelcol-sumo
            fi
            ;;
    esac
}

function get_user_env_config() {
    local file
    readonly file="${1}"

    if [[ ! -f "${file}" ]]; then
        return
    fi

    # extract install_token and strip quotes
    grep -m 1 "${ENV_TOKEN}" "${file}" \
        | sed "s/.*${ENV_TOKEN}=[[:blank:]]*//" \
        | sed 's/[[:blank:]]*$//' \
        | sed 's/^"//' \
        | sed "s/^'//" \
        | sed 's/"$//' \
        | sed "s/'\$//" \
    || grep -m 1 "${DEPRECATED_ENV_TOKEN}" "${file}" \
        | sed "s/.*${DEPRECATED_ENV_TOKEN}=[[:blank:]]*//" \
        | sed 's/[[:blank:]]*$//' \
        | sed 's/^"//' \
        | sed "s/^'//" \
        | sed 's/"$//' \
        | sed "s/'\$//" \
    || echo ""
}

function get_launchd_token() {
    local file
    readonly file="${1}"

    if [[ "${OS_TYPE}" != "darwin" ]]; then
        return
    fi

    if [[ ! -f "${file}" ]]; then
        return
    fi

    plutil_extract_key "${file}" "${LAUNCHD_TOKEN_KEY}"
}

function get_user_api_url() {
    if command -v "${SUMO_CONFIG_BINARY_PATH}" &> /dev/null; then
        KV=$("${SUMO_CONFIG_BINARY_PATH}" --read-kv .extensions.sumologic.api_base_url)
        if [[ "${KV}" != "null" ]]; then
            echo "${KV}"
        fi
    fi
}

function get_user_opamp_endpoint() {
    if command -v "${SUMO_CONFIG_BINARY_PATH}" &> /dev/null; then
        KV=$("${SUMO_CONFIG_BINARY_PATH}" --read-kv .extensions.opamp.endpoint)
        if [[ "${KV}" != "null" ]]; then
            echo "${KV}"
        fi
    fi
}

# write installation token to user configuration file
function write_installation_token() {
    local token
    readonly token="${1}"

    "${SUMO_CONFIG_BINARY_PATH}" --set-installation-token "$token"
}

# write ${ENV_TOKEN} to launchd configuration file
function write_installation_token_launchd() {
    local token
    readonly token="${1}"

    local file
    readonly file="${2}"

    if [[ ! -f "${file}" ]]; then
        echo "The LaunchDaemon configuration file is missing: ${file}"
        exit 1
    fi

    # Create EnvironmentVariables key if it does not exist
    if ! plutil_key_exists "${file}" "${LAUNCHD_ENV_KEY}"; then
        plutil_create_key "${file}" "${LAUNCHD_ENV_KEY}" "xml" "<dict/>"
    fi

    # Replace EnvironmentVariables key if it has an incorrect type
    if ! plutil_key_is_type "${file}" "${LAUNCHD_ENV_KEY}" "dictionary"; then
        plutil_replace_key "${file}" "${LAUNCHD_ENV_KEY}" "xml" "<dict/>"
    fi

    # Create SUMOLOGIC_INSTALLATION_TOKEN key if it does not exist otherwise
    # replace the SUMOLOGIC_INSTALLATION_TOKEN key
    if ! plutil_key_exists "${file}" "${LAUNCHD_TOKEN_KEY}"; then
        plutil_create_key "${file}" "${LAUNCHD_TOKEN_KEY}" "string" "${token}"
    else
        plutil_replace_key "${file}" "${LAUNCHD_TOKEN_KEY}" "string" "${token}"
    fi
}

# write sumologic ephemeral: true to user configuration file
function write_ephemeral_true() {
    "${SUMO_CONFIG_BINARY_PATH}" --enable-ephemeral
}

# write api_url to user configuration file
function write_api_url() {
    local api_url
    readonly api_url="${1}"

    "${SUMO_CONFIG_BINARY_PATH}" --set-api-url "$api_url"
}

# write opamp endpoint to user configuration file
function write_opamp_endpoint() {
    local opamp_endpoint
    readonly opamp_endpoint="${1}"

    "${SUMO_CONFIG_BINARY_PATH}" --set-opamp-endpoint "$opamp_endpoint"
}

# write tags to user configuration file
function write_tags() {
    arr=("$@")
    for field in "${arr[@]}";
    do
        "${SUMO_CONFIG_BINARY_PATH}" --add-tag "$field"
    done
}

# configure and enable the opamp extension for remote management
function write_opamp_extension() {
    "${SUMO_CONFIG_BINARY_PATH}" --enable-remote-control
}

# NB: this function is only for Darwin
function get_package_from_url() {
    local url download_filename download_path curl_args
    readonly url="${1}"
    echo -e "Downloading:\t\t${url}"

    download_filename=$(basename "${url}")
    readonly download_filename
    readonly download_path="${DOWNLOAD_CACHE_DIR}/${download_filename}"
    curl_args=(
        "-fL"
        "--connect-timeout" "5"
        "--max-time" "${CURL_MAX_TIME}"
        "--retry" "5"
        "--retry-delay" "0"
        "--retry-max-time" "150"
        "--output" "${download_path}"
        "--progress-bar"
    )
    if [ "${KEEP_DOWNLOADS}" == "true" ]; then
        curl_args+=("-z" "${download_path}")
    fi
    curl "${curl_args[@]}" "${url}"

    cp -f "${download_path}" "${TMPDIR}/otelcol-sumo.pkg"

    if [ "${KEEP_DOWNLOADS}" == "false" ]; then
        rm -f "${download_path}"
    fi
}

function plutil_create_key() {
    local file key type value
    readonly file="${1}"
    readonly key="${2}"
    readonly type="${3}"
    readonly value="${4}"

    if ! plutil -insert "${key}" -"${type}" "${value}" "${file}"; then
        echo "plutil_create_key error: key=${key}, type=${type}, value=${value}, file=${file}"
        exit 1
    fi
}

function plutil_extract_key() {
    local file key output
    readonly file="${1}"
    readonly key="${2}"

    if output="$(plutil -extract "${key}" raw -o - "${file}")"; then
        echo "${output}"
    else
        echo
    fi
}

function plutil_key_exists() {
    local file key
    readonly file="${1}"
    readonly key="${2}"

    plutil -type "${key}" "${file}" > /dev/null 2>&1
}

function plutil_key_is_type() {
    local file key type
    readonly file="${1}"
    readonly key="${2}"
    readonly type="${3}"

    plutil -type "${key}" -expect "${type}" "${file}" > /dev/null 2>&1
}

function plutil_replace_key() {
    local file key type value
    readonly file="${1}"
    readonly key="${2}"
    readonly type="${3}"
    readonly value="${4}"

    if ! plutil -replace "${key}" -"${type}" "${value}" "${file}"; then
        echo "plutil_replace_key error: key=${key}, file=${file}"
        exit 1
    fi
}

function get_package_manager() {
    if which dnf > /dev/null 2>&1; then
        echo "dnf"
    elif which yum > /dev/null 2>&1; then
        echo "yum"
    elif which apt-get > /dev/null 2>&1; then
        echo "apt-get"
    else
        echo "package manager not found [dnf, yum, apt-get]"
        exit 1
    fi
}

function install_linux_package() {
    local package_name
    readonly package_name="${1}"

    if [[ "${PACKAGECLOUD_MASTER_TOKEN}" != "" ]]; then
      base_url="https://${PACKAGECLOUD_MASTER_TOKEN}:@packages.sumologic.com"
    else
      base_url="https://packages.sumologic.com"
    fi
    base_url+="/install/repositories/${PACKAGECLOUD_ORG}/${PACKAGECLOUD_REPO}"

    repo_id="${PACKAGECLOUD_ORG}_${PACKAGECLOUD_REPO}"

    case $(get_package_manager) in
        yum | dnf)
            curl -s "${base_url}/script.rpm.sh" | bash

            local package_str
            package_str="${package_name}"
            if [[ -n "${VERSION}" ]]; then
                package_str="${package_str}-${VERSION}"
            fi
            echo "Installing ${package_str}"
            yum install --quiet -y "${package_str}"
            ;;
        apt-get)
            curl -s "${base_url}/script.deb.sh" | bash
            apt-get update --quiet -y -o Dir::Etc::sourcelist="sources.list.d/${repo_id}"

            local package_str
            package_str="${package_name}"
            if [[ -n "${VERSION}" ]]; then
                package_str="${package_str}=${VERSION}"
            fi
            echo "Installing ${package_str}"
            apt-get install --quiet -y "${package_str}"
            ;;
    esac
}

function show_upgrade_instructions() {
    echo -n "Upgrades can be performed using the native package manager: "

    case $(get_package_manager) in
        yum | dnf)
            echo "yum update otelcol-sumo -y"
            ;;
        apt-get)
            echo "apt-get update && apt-get upgrade otelcol-sumo -y"
            ;;
    esac
}

function check_deprecated_linux_flags() {
    if [[ -n "${BINARY_BRANCH}" ]]; then
        echo "warning: --binary-branch is deprecated"
        exit 1
    fi

    if [[ -n "${CONFIG_BRANCH}" ]]; then
        echo "warning: --config-branch is deprecated"
    fi

    if [[ "${OS_TYPE}" == "darwin" ]]; then
        return
    fi

    if [[ -n "${DOWNLOAD_ONLY}" ]]; then
        echo "--download-only is only supported on darwin"
        show_upgrade_instructions
        exit 1
    fi
}

function is_package_installed() {
    case $(get_package_manager) in
        yum | dnf)
            # TODO: refine exact command
            yum --cacheonly list --installed otelcol-sumo > /dev/null 2>&1
            ;;
        apt-get)
            dpkg --status otelcol-sumo > /dev/null 2>&1
            ;;
    esac
}

# Try to infer if there is a binary, pre-packaging rework installation, the
# kind of installation that was performed by downloading artifacts from Github,
# before we moved to using distribution packages.
function has_prepackaging_installation() {
    if command -v otelcol-sumo > /dev/null 2>&1 && ! is_package_installed; then
        true
    else
        false
    fi
}

function backup_prepackaging_configuration() {
    cp -r "${CONFIG_DIRECTORY}" "${TMPDIR}/otelcol-sumo-configuration-backup"
}

function restore_prepackaging_configuration() {
    echo "restore_prepackaging_configuration(): not implemented yet"
}

function uninstall_prepackaging_installation() {
    # Stop the service and remove its unit file
    SYSTEMD_SERVICE_PATH="/etc/systemd/system/otelcol-sumo.service"
    if [[ -f "${SYSTEMD_SERVICE_PATH}" ]]; then
        systemctl --quiet stop otelcol-sumo || true
        systemctl --quiet disable otelcol-sumo || true
        rm -f "${SYSTEMD_SERVICE_PATH}"
    fi

    # Remove the old binary
    rm -f "${SUMO_BINARY_PATH}"

    # Remove old configuration and data
    FILE_STORAGE="/var/lib/otelcol-sumo/file_storage"
    rm -rf "${CONFIG_DIRECTORY}" "${FILE_STORAGE}"

    # Remove the otelcol-sumo user and group
    SYSTEM_USER="otelcol-sumo"
    userdel --remove --force "${SYSTEM_USER}" 2>/dev/null || true
    groupdel "${SYSTEM_USER}" 2>/dev/null || true
}

############################ Main code

OS_TYPE="$(get_os_type)"
ARCH_TYPE="$(get_arch_type)"
readonly OS_TYPE ARCH_TYPE

echo -e "Detected OS type:\t${OS_TYPE}"
echo -e "Detected architecture:\t${ARCH_TYPE}"

set_defaults
parse_options "$@"
set_tmpdir
check_dependencies
check_deprecated_linux_flags

readonly SUMOLOGIC_INSTALLATION_TOKEN API_BASE_URL OPAMP_API_URL FIELDS CONTINUE CONFIG_DIRECTORY UNINSTALL
readonly USER_ENV_DIRECTORY CONFIG_DIRECTORY COMMON_CONFIG_PATH
readonly INSTALL_HOSTMETRICS
readonly REMOTELY_MANAGED
readonly CURL_MAX_TIME
readonly LAUNCHD_CONFIG LAUNCHD_ENV_KEY LAUNCHD_TOKEN_KEY

if [[ "${UNINSTALL}" == "true" ]]; then
    uninstall
    exit 0
fi
if [[ "${UPGRADE}" == "true" ]]; then
    upgrade
    exit 0
fi

# get_installation_token returns the value of SUMOLOGIC_INSTALLATION_TOKEN
# (set by a flag or environment variable) when it is not empty, otherwise it
# will attempt to fetch the token from an existing installation and return it.
function get_installation_token() {
  local token=""

  if [[ -z "${token}" ]]; then
    token="${SUMOLOGIC_INSTALLATION_TOKEN}"
  fi

  if [[ -z "${token}" ]]; then
    token="$(get_user_token)"
  fi

  echo "${token}"
}

# Attempt to find a token from an existing installation
function get_user_token() {
  local token="${USER_TOKEN}"

  # Attempt to find a token from an existing installation
  # Check the systemd env file for a token
  if [[ -f "${TOKEN_ENV_FILE}" && -z "${token}" ]]; then
    token="$(get_user_env_config "${TOKEN_ENV_FILE}")"
  fi

  # Check the launchd config for a token
  if [[ -f "${LAUNCHD_CONFIG}" && -z "${token}" ]]; then
    token="$(get_launchd_token "${LAUNCHD_CONFIG}")"
  fi

  # Check yaml configuration for a token
  if [[ -z "${token}" ]]; then
    if command -v "${SUMO_CONFIG_BINARY_PATH}" &> /dev/null; then
      local output=""
      output=$("${SUMO_CONFIG_BINARY_PATH}" --read-kv .extensions.sumologic.installation_token)
      if [[ "${output}" != "null" ]]; then
        token="${output}"
      fi
    fi
  fi

  echo "${token}"
}

# Load & cache user token
USER_TOKEN="$(get_user_token)"

# Exit if installation token is not set by flag, environment variable, or from
# existing installation configuration. Skip this check when DOWNLOAD_ONLY is set
# which is only possible on macOS.
if [[ -z "$(get_installation_token)" && -z "${DOWNLOAD_ONLY}" ]]; then
  echo "Installation token has not been provided. Please set the '${ENV_TOKEN}' environment variable."
  exit 1
fi

if [ "${FIPS}" == "true" ]; then
    case "${OS_TYPE}" in
    linux)
        if  [ "${ARCH_TYPE}" != "amd64" ] && [ "${ARCH_TYPE}" != "arm64" ]; then
            echo "Error: The FIPS-approved binary is only available for linux/amd64 and linux/arm64"
            exit 1
        fi
        ;;
    *)
        echo "Error: The FIPS-approved binary is only available for linux"
        exit 1
        ;;
    esac
fi

if [[ "${OS_TYPE}" == "darwin" ]]; then
    # verify if passed arguments are the same like in user's configuration
    if [[ -z "${DOWNLOAD_ONLY}" ]]; then
        USER_TOKEN="$(get_user_token)"
        if [[ -n "${USER_TOKEN}" && -n "${SUMOLOGIC_INSTALLATION_TOKEN}" && "${USER_TOKEN}" != "${SUMOLOGIC_INSTALLATION_TOKEN}" ]]; then
            echo "You are trying to install with different token than in your configuration file!"
            exit 1
        fi

        USER_API_URL="$(get_user_api_url)"
        if [[ -n "${USER_API_URL}" && -n "${API_BASE_URL}" && "${USER_API_URL}" != "${API_BASE_URL}" ]]; then
            echo "You are trying to install with different api base url than in your configuration file! (${USER_API_URL} != ${API_BASE_URL})"
            exit 1
        fi

        USER_OPAMP_API_URL="$(get_user_opamp_endpoint "${COMMON_CONFIG_PATH}")"
        if [[ -n "${USER_OPAMP_API_URL}" && -n "${OPAMP_API_URL}" && "${USER_OPAMP_API_URL}" != "${OPAMP_API_URL}" ]]; then
            echo "You are trying to install with different opamp endpoint than in your configuration file!"
            exit 1
        fi
    fi

    package_arch=""
    case "${ARCH_TYPE}" in
      "amd64") package_arch="intel" ;;
      "arm64") package_arch="apple" ;;
      *)
        echo "Unsupported architecture for darwin: ${ARCH_TYPE}"
        exit 1
        ;;
    esac
    readonly package_arch

    pkg_url=""

    if [[ -z "${DARWIN_PKG_URL}" ]]; then
        # Use user's version if set, otherwise get latest version from API (or website)
        if [[ -z "${VERSION}" ]]; then
            echo -e "Getting latest version..."
            VERSION="$(get_latest_s3_package_version)"
        fi

        readonly VERSION

        echo -e "Version to install:\t${VERSION}"

        artifact_name="otelcol-sumo_${VERSION}-${package_arch}.pkg"
        readonly artifact_name

        pkg_url="${S3_URI}/${VERSION}/${artifact_name}"
    else
        pkg_url="${DARWIN_PKG_URL}"
    fi

    get_package_from_url "${pkg_url}"

    pkg="${TMPDIR}/otelcol-sumo.pkg"

    if [[ "${DOWNLOAD_ONLY}" == "true" ]]; then
        echo "Package downloaded to: ${pkg}"
        exit 0
    fi

    echo "Installing otelcol-sumo package"
    installer -pkg "${pkg}" -target /

    # The token must be written to the launchd config on every install as
    # upgrades replace the launchd config
    echo "Writing installation token to launchd config"
    write_installation_token_launchd "$(get_installation_token)" "${LAUNCHD_CONFIG}"

    setup_config_darwin

    # Run an unload/load launchd config to pull in new changes & restart the service
    launchctl unload "${LAUNCHD_CONFIG}"
    launchctl load -w "${LAUNCHD_CONFIG}"

    echo "Waiting for otelcol to start"
    while ! launchctl print system/otelcol-sumo | grep -q "state = running"; do
        echo -n "  otelcol service "
        launchctl print system/otelcol-sumo | grep "state = "
        sleep 1
    done
    OTEL_EXITED_WITH_ERROR=false
    echo 'Checking otelcol status'
    for _ in {1..15}; do
        if launchctl print system/otelcol-sumo | grep -q "last exit code = 1"; then
            OTEL_EXITED_WITH_ERROR=true
            break;
        fi
        sleep 0.4
    done
    if [[ "${OTEL_EXITED_WITH_ERROR}" == "true" ]]; then
        echo "Failed to launch otelcol"
        tail /var/log/otelcol-sumo/otelcol-sumo.log
        exit 1
    fi
    echo "Successfully started otelcol"
    exit 0
fi

package_name=""
if [[ "${FIPS}" == "true" ]]; then
  echo "Getting FIPS-compliant binary"
  package_name=otelcol-sumo-fips
else
  package_name=otelcol-sumo
fi

if has_prepackaging_installation; then
   # Display a warning and information message here?
   echo 'Pre-packaging installation detected'

   # Backup current configuration
   backup_prepackaging_configuration

   # Remove current installation
   uninstall_prepackaging_installation

   # We can now proceed and install using the packages and attempt to restore
   # the configuration later.
   HAD_PREPACKAGING_INSTALLATION="true"
fi

if is_package_installed; then
    echo "The otelcol-sumo package is already installed"
    show_upgrade_instructions
    exit 1
fi

install_linux_package "${package_name}"
verify_installation
setup_config

# If an old, pre-packaging rework installation was removed during this run,
# attempt the restore the configuration that was backed up during that removal.
set +u
if [[ -n "${HAD_PREPACKAGING_INSTALLATION}" ]]; then
    restore_prepackaging_configuration
fi
set -u

echo 'Reloading systemd'
systemctl daemon-reload

echo 'Enable otelcol-sumo service'
systemctl enable otelcol-sumo

echo 'Starting otelcol-sumo service'
systemctl restart otelcol-sumo

exit 0
