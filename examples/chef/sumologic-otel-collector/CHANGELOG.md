# Changelog

All notable changes to the sumologic-otel-collector cookbook will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-03-30

### Added

- Initial release of sumologic-otel-collector Chef cookbook
- Support for Linux platforms (Ubuntu, Debian, RHEL, CentOS, Amazon Linux, SUSE)
- Support for Windows platforms (Windows Server 2016+, Windows 10+)
- Custom resource for installing and configuring Sumo Logic OpenTelemetry Collector
- Multiple credential storage methods:
  - Chef Vault integration (requires Chef Server)
  - Encrypted Data Bags support
  - Node attributes (works with chef-solo)
- Configurable collector tags for data classification
- Support for remotely managed collectors via OpAmp
- Systemd service management on Linux
- Windows service management
- Custom configuration directory support
- Comprehensive documentation:
  - README.md with usage examples
  - CONTRIBUTING.md for developers
  - TESTING.md for testing procedures
- Chef-solo support for single-machine deployments

### Features

- Automatic installation of latest or specific version of otelcol-sumo
- Flexible attribute-based configuration
- Cross-platform resource implementation
- Service enable and start management
- Configuration file management
- Support for custom API and OpAmp endpoints

### Platforms

- Ubuntu (all supported versions)
- Debian (all supported versions)
- RHEL/CentOS (all supported versions)
- Amazon Linux (all supported versions)
- Windows Server 2016+
- Windows 10+
- SUSE (all supported versions)

### Requirements

- Chef Infra Client/Workstation 15.3 or higher
- Ruby 2.6 or higher

[1.0.0]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/releases/tag/chef-v1.0.0
