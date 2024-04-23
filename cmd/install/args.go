package main

import (
	"os"
	"strconv"

	"github.com/spf13/pflag"
)

// These consts are lifted more or less directly from the old bash script.
// Although they use non-standard naming for a Go program, it's probably
// worth keeping the names the same as in the bash script for now.
const (
	ARG_SHORT_TOKEN               = "i"
	ARG_LONG_TOKEN                = "installation-token"
	ARG_SHORT_HELP                = "h"
	ARG_LONG_HELP                 = "help"
	ARG_SHORT_API                 = "a"
	ARG_LONG_API                  = "api"
	ARG_SHORT_TAG                 = "t"
	ARG_LONG_TAG                  = "tag"
	ARG_SHORT_VERSION             = "v"
	ARG_LONG_VERSION              = "version"
	ARG_SHORT_FIPS                = "f"
	ARG_LONG_FIPS                 = "fips"
	ARG_SHORT_YES                 = "y"
	ARG_LONG_YES                  = "yes"
	ARG_SHORT_SKIP_SYSTEMD        = "d"
	ARG_LONG_SKIP_SYSTEMD         = "skip-systemd"
	ARG_SHORT_SKIP_CONFIG         = "s"
	ARG_LONG_SKIP_CONFIG          = "skip-config"
	ARG_SHORT_UNINSTALL           = "u"
	ARG_LONG_UNINSTALL            = "uninstall"
	ARG_SHORT_PURGE               = "p"
	ARG_LONG_PURGE                = "purge"
	ARG_SHORT_SKIP_TOKEN          = "k"
	ARG_LONG_SKIP_TOKEN           = "skip-installation-token"
	ARG_SHORT_DOWNLOAD            = "w"
	ARG_LONG_DOWNLOAD             = "download-only"
	ARG_SHORT_CONFIG_BRANCH       = "c"
	ARG_LONG_CONFIG_BRANCH        = "config-branch"
	ARG_SHORT_BINARY_BRANCH       = "e"
	ARG_LONG_BINARY_BRANCH        = "binary-branch"
	ARG_SHORT_BRANCH              = "b"
	ARG_LONG_BRANCH               = "branch"
	ARG_SHORT_KEEP_DOWNLOADS      = "n"
	ARG_LONG_KEEP_DOWNLOADS       = "keep-downloads"
	ARG_SHORT_INSTALL_HOSTMETRICS = "H"
	ARG_LONG_INSTALL_HOSTMETRICS  = "install-hostmetrics"
	ARG_SHORT_REMOTELY_MANAGED    = "r"
	ARG_LONG_REMOTELY_MANAGED     = "remotely-managed"
	ARG_SHORT_EPHEMERAL           = "E"
	ARG_LONG_EPHEMERAL            = "ephemeral"
	ARG_SHORT_TIMEOUT             = "m"
	ARG_LONG_TIMEOUT              = "download-timeout"
	PACKAGE_GITHUB_ORG            = "SumoLogic"
	PACKAGE_GITHUB_REPO           = "sumologic-otel-collector-packaging"
)

const (
	DocToken   = `Installation token. It has precedence over 'SUMOLOGIC_INSTALLATION_TOKEN' env variable.`
	DocAPI     = `API URL, forces the collector to use non-default API`
	DocTag     = `Sets tag for collector. This argument can be use multiple times. One per tag.`
	DocVersion = `Version of Sumo Logic Distribution for OpenTelemetry Collector to install, e.g. 0.57.2-sumo-1.
By default it gets latest version.`
	DocFIPS        = `Install the FIPS 140-2 compliant binary on Linux.`
	DocSkipSystemd = `Do not install systemd unit.`
	DocSkipConfig  = `Do not create default configuration.`
	DocUninstall   = `Removes Sumo Logic Distribution for OpenTelemetry Collector from the system and
disable Systemd service eventually.
Use with '--purge' to remove all configurations as well.`
	DocPurge              = `Remove all Sumo Logic Distribution for OpenTelemetry Collector related configuration and data.`
	DocSkipToken          = `Skips requirement for installation token.`
	DocDownloadOnly       = `Download new binary only and skip configuration part.`
	DocInstallHostmetrics = `Install the hostmetrics configuration to collect host metrics.`
	DocRemotelyManaged    = `Remotely manage the collector configuration with Sumo Logic.`
	DocEphemeral          = `Delete the collector from Sumo Logic after 12 hours of inactivity.`
	DocTimeout            = `Timeout in seconds after which download will fail. Default is ${CURL_MAX_TIME}.`
	DocYes                = `Disable confirmation asks.`
	DocHelp               = `Prints this help and usage.`
	NoDoc                 = `` // placeholder for actual documentation
)

var flagSet = pflag.NewFlagSet("install", pflag.ContinueOnError)

// ArgBag is a record that holds all the parsed arguments.
type ArgBag struct {
	InstallationToken     string
	Help                  bool
	API                   string
	Tag                   string
	Version               string
	FIPS                  bool
	Yes                   bool
	SkipSystemd           bool
	SkipConfig            bool
	Uninstall             bool
	Purge                 bool
	SkipInstallationToken bool
	DownloadOnly          bool
	ConfigBranch          string
	BinaryBranch          string
	Branch                string
	KeepDownloads         bool
	InstallHostmetrics    bool
	RemotelyManaged       bool
	Ephemeral             bool
	DownloadTimeout       int64
}

func getDefaultTimeout() int64 {
	defaultTimeoutString := os.Getenv("CURL_MAX_TIME")
	defaultTimeout := int64(600)
	if defaultTimeoutString != "" {
		i, err := strconv.ParseInt(defaultTimeoutString, 10, 64)
		if err == nil {
			defaultTimeout = i
		}
	}
	return defaultTimeout
}

// NewArgBag makes a new ArgBag and sets up all the flags with the provided FlagSet.
func NewArgBag(f *pflag.FlagSet) *ArgBag {
	a := ArgBag{}
	f.StringVarP(&a.InstallationToken, ARG_LONG_TOKEN, ARG_SHORT_TOKEN, "", DocToken)
	f.BoolVarP(&a.Help, ARG_LONG_HELP, ARG_SHORT_HELP, false, DocHelp)
	f.StringVarP(&a.API, ARG_LONG_API, ARG_SHORT_API, "", DocAPI)
	f.StringVarP(&a.Version, ARG_LONG_VERSION, ARG_SHORT_VERSION, "", DocVersion)
	f.BoolVarP(&a.FIPS, ARG_LONG_FIPS, ARG_SHORT_FIPS, false, DocFIPS)
	f.BoolVarP(&a.Yes, ARG_LONG_YES, ARG_SHORT_YES, false, DocYes)
	f.BoolVarP(&a.SkipSystemd, ARG_LONG_SKIP_SYSTEMD, ARG_SHORT_SKIP_SYSTEMD, false, DocSkipSystemd)
	f.BoolVarP(&a.SkipConfig, ARG_LONG_SKIP_CONFIG, ARG_SHORT_SKIP_CONFIG, false, DocSkipConfig)
	f.BoolVarP(&a.Uninstall, ARG_LONG_UNINSTALL, ARG_SHORT_UNINSTALL, false, DocUninstall)
	f.BoolVarP(&a.Purge, ARG_LONG_PURGE, ARG_SHORT_PURGE, false, DocPurge)
	f.BoolVarP(&a.SkipInstallationToken, ARG_LONG_SKIP_TOKEN, ARG_SHORT_SKIP_TOKEN, false, DocSkipToken)
	f.BoolVarP(&a.DownloadOnly, ARG_LONG_DOWNLOAD, ARG_SHORT_DOWNLOAD, false, DocDownloadOnly)
	f.StringVarP(&a.ConfigBranch, ARG_LONG_CONFIG_BRANCH, ARG_SHORT_CONFIG_BRANCH, "", NoDoc)
	f.StringVarP(&a.BinaryBranch, ARG_LONG_BINARY_BRANCH, ARG_SHORT_BINARY_BRANCH, "", NoDoc)
	f.StringVarP(&a.Branch, ARG_LONG_BRANCH, ARG_SHORT_BRANCH, "", NoDoc)
	f.BoolVarP(&a.KeepDownloads, ARG_LONG_KEEP_DOWNLOADS, ARG_SHORT_KEEP_DOWNLOADS, false, NoDoc)
	f.BoolVarP(&a.InstallHostmetrics, ARG_LONG_INSTALL_HOSTMETRICS, ARG_SHORT_INSTALL_HOSTMETRICS, false, NoDoc)
	f.BoolVarP(&a.RemotelyManaged, ARG_LONG_REMOTELY_MANAGED, ARG_SHORT_REMOTELY_MANAGED, false, DocRemotelyManaged)
	f.BoolVarP(&a.Ephemeral, ARG_LONG_EPHEMERAL, ARG_SHORT_EPHEMERAL, false, DocEphemeral)
	f.Int64VarP(&a.DownloadTimeout, ARG_LONG_TIMEOUT, ARG_SHORT_TIMEOUT, getDefaultTimeout(), DocTimeout)
	return &a
}

// ParseArgs parses the arguments provided to it and returns a populated ArgBag.
func ParseArgs(flags *pflag.FlagSet, args []string) (*ArgBag, error) {
	argBag := NewArgBag(flags)
	if err := flags.Parse(os.Args); err != nil {
		return nil, err
	}
	return argBag, nil
}
