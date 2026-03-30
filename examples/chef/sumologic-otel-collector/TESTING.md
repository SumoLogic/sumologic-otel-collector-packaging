# Testing Sumo Logic OpenTelemetry Collector Chef Cookbook

This document provides detailed instructions for testing the Chef cookbook on various platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Testing on Linux](#testing-on-linux)
- [Testing on Windows](#testing-on-windows)
- [Testing with Different Configurations](#testing-with-different-configurations)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- **Chef Workstation** or **Chef Client** with chef-solo installed
- **Sumo Logic Installation Token** - Get from [Sumo Logic](https://help.sumologic.com/docs/manage/security/installation-tokens/)

## Testing on Linux

### 1. Prepare Test Environment

Navigate to the cookbook directory:

```bash
cd examples/chef
```

### 2. Create Test Wrapper Cookbook

Create the wrapper cookbook structure:

```bash
mkdir -p my-sumologic-wrapper/attributes
mkdir -p my-sumologic-wrapper/recipes
```

### 3. Configure Attributes

Create `my-sumologic-wrapper/attributes/default.rb`:

```ruby
# Required: Your Sumo Logic installation token
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'

# Optional: Collector tags
default['sumologic_otel_collector']['collector_tags'] = {
  'environment' => 'test',
  'team' => 'testing'
}

# Optional: API URL (uncomment if needed)
# default['sumologic_otel_collector']['api_url'] = 'https://your-api-url.com'

# Optional: Specific version (uncomment if needed)
# default['sumologic_otel_collector']['version'] = '0.148.0'

# Optional: Custom config path (uncomment if needed)
# default['sumologic_otel_collector']['src_config_path'] = '/etc/otelcol-sumo/conf.d'

# Optional: Enable remote management (uncomment if needed)
# default['sumologic_otel_collector']['remotely_managed'] = true
# default['sumologic_otel_collector']['opamp_api_url'] = 'wss://opamp-events.sumologic.net/v1/opamp'
```

### 4. Create Recipe

Create `my-sumologic-wrapper/recipes/default.rb`:

```ruby
include_recipe 'sumologic-otel-collector::default'
```

### 5. Create Metadata

Create `my-sumologic-wrapper/metadata.rb`:

```ruby
name 'my-sumologic-wrapper'
version '0.1.0'
depends 'sumologic-otel-collector'
```

### 6. Run chef-solo

Execute the cookbook:

```bash
sudo chef-solo -o 'recipe[my-sumologic-wrapper]' --config-option cookbook_path=$(pwd)
```

### 7. Verify Installation

Check service status:

```bash
# Check if service is running
sudo systemctl status otelcol-sumo

# View logs
sudo journalctl -u otelcol-sumo -f

# Check process
sudo ps aux | grep otelcol-sumo
```

## Testing on Windows

### 1. Prepare Test Environment (Windows)

Open PowerShell as Administrator and navigate to the cookbook directory:

```powershell
cd examples\chef
```

### 2. Create Test Wrapper Cookbook (Windows)

Create the wrapper cookbook structure:

```powershell
New-Item -ItemType Directory -Path "my-sumologic-wrapper\attributes" -Force
New-Item -ItemType Directory -Path "my-sumologic-wrapper\recipes" -Force
```

### 3. Configure Attributes (Windows)

Create `my-sumologic-wrapper\attributes\default.rb`:

```ruby
# Required: Your Sumo Logic installation token
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'

# Optional: Collector tags
default['sumologic_otel_collector']['collector_tags'] = {
  'environment' => 'test',
  'team' => 'testing'
}
```

### 4. Create Recipe (Windows)

Create `my-sumologic-wrapper\recipes\default.rb`:

```ruby
include_recipe 'sumologic-otel-collector::default'
```

### 5. Create Metadata (Windows)

Create `my-sumologic-wrapper\metadata.rb`:

```ruby
name 'my-sumologic-wrapper'
version '0.1.0'
depends 'sumologic-otel-collector'
```

### 6. Run chef-solo (Windows)

Execute the cookbook:

```powershell
chef-solo -o 'recipe[my-sumologic-wrapper]' --config-option cookbook_path="$PWD"
```

### 7. Verify Installation (Windows)

Check service status:

```powershell
# Check service status
Get-Service -Name OtelcolSumo

# View service details
Get-Service -Name OtelcolSumo | Select-Object *

# Check if binary exists
Test-Path "C:\Program Files\Sumo Logic\OpenTelemetry Collector\otelcol-sumo.exe"

# View service in Services console
services.msc
```

## Testing with Different Configurations

### Test 1: Basic Installation (Default Configuration)

Use minimal attributes:

```ruby
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'
```

### Test 2: With Custom Tags

```ruby
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'
default['sumologic_otel_collector']['collector_tags'] = {
  'host.group' => 'production',
  'deployment.environment' => 'prod',
  'region' => 'us-east-1'
}
```

### Test 3: With Specific Version

```ruby
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'
default['sumologic_otel_collector']['version'] = '0.147.0'
```

### Test 4: With Custom Configuration Directory

```ruby
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'
default['sumologic_otel_collector']['src_config_path'] = '/custom/config/path'
```

### Test 5: Remotely Managed Collector

```ruby
default['sumologic_otel_collector']['installation_token'] = 'YOUR_TOKEN_HERE'
default['sumologic_otel_collector']['remotely_managed'] = true
default['sumologic_otel_collector']['opamp_api_url'] = 'wss://opamp-events.sumologic.net/v1/opamp'
```

### Test 6: Using JSON Configuration (Alternative Method)

Create `node.json`:

```json
{
  "sumologic_otel_collector": {
    "installation_token": "YOUR_TOKEN_HERE",
    "collector_tags": {
      "environment": "test",
      "team": "testing"
    }
  },
  "run_list": ["recipe[sumologic-otel-collector]"]
}
```

Run with:

```bash
sudo chef-solo -j node.json --config-option cookbook_path=$(pwd)
```

## Verification

### Verify Collector is Running

**Linux:**

```bash
# Service status
sudo systemctl status otelcol-sumo

# Check if listening on ports
sudo netstat -tlnp | grep otelcol

# View recent logs
sudo journalctl -u otelcol-sumo --since "5 minutes ago"
```

**Windows:**

```powershell
# Service status
Get-Service -Name OtelcolSumo

# Check process
Get-Process | Where-Object {$_.Name -like "*otelcol*"}

# View event logs
Get-EventLog -LogName Application -Source "OtelcolSumo" -Newest 10
```

### Verify Configuration Files

**Linux:**

```bash
# Check config directory
ls -la /etc/otelcol-sumo/

# View configuration
cat /etc/otelcol-sumo/sumologic.yaml
```

**Windows:**

```powershell
# Check config directory
Get-ChildItem "C:\ProgramData\Sumo Logic\OpenTelemetry Collector\config"

# View configuration
Get-Content "C:\ProgramData\Sumo Logic\OpenTelemetry Collector\config\sumologic.yaml"
```

## Troubleshooting

### Common Issues

#### Issue: chef-solo command not found

**Solution:**

```bash
# Verify Chef is installed
which chef-solo

# If not installed, please install Chef Workstation or Chef Client
```

#### Issue: Installation token error

**Error:**

```text
FATAL: Sumo Logic installation token not provided!
```

**Solution:**

- Verify the token is correctly set in attributes file
- Check for extra quotes or spaces
- Ensure the token is valid and not expired

#### Issue: Service fails to start (Linux)

**Error:**

```text
Failed to start otelcol-sumo service
```

**Solution:**

```bash
# Check detailed logs
sudo journalctl -u otelcol-sumo -n 50

# Check config syntax
sudo /usr/local/bin/otelcol-sumo --config /etc/otelcol-sumo/sumologic.yaml validate

# Check file permissions
ls -la /etc/otelcol-sumo/
```

#### Issue: Service fails to start (Windows)

**Error:**

```text
Failed to start service 'Sumo Logic OpenTelemetry Collector (OtelcolSumo)'
```

**Solution:**

```powershell
# Check event logs
Get-EventLog -LogName Application -Newest 20 | Where-Object {$_.Message -like "*otelcol*"}

# Verify binary exists
Test-Path "C:\Program Files\Sumo Logic\OpenTelemetry Collector\otelcol-sumo.exe"

# Try starting manually
Start-Service -Name OtelcolSumo -Verbose
```

#### Issue: Package download failure (Linux)

**Error:**

```text
Error downloading packages: Cannot download, all mirrors were already tried
```

**Solution:**

```bash
# Update package cache
sudo yum clean all && sudo yum makecache

# Or for apt-based systems
sudo apt-get clean && sudo apt-get update

# Check network connectivity
curl -I https://packages.sumologic.com/

# Try installing manually
sudo yum install -y otelcol-sumo  # RPM-based
sudo apt-get install -y otelcol-sumo  # DEB-based
```

#### Issue: Chef run fails with syntax error

**Error:**

```text
SyntaxError: unexpected local variable or method
```

**Solution:**

- Check Ruby syntax in attributes file
- Ensure proper use of hash rocket `=>` syntax
- Verify all quotes are properly closed
- Check for extra single quotes (common with copy-paste)

### Getting Help

If you encounter issues not covered here:

1. Check the [main README.md](README.md)
2. Review [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
3. Search [existing issues](https://github.com/SumoLogic/sumologic-otel-collector-packaging/issues)
4. Create a new issue with:
   - Platform and OS version
   - Chef version
   - Full error output
   - Relevant configuration files (redact sensitive data)

## Clean Up Test Installation

### Linux

```bash
# Stop service
sudo systemctl stop otelcol-sumo

# Disable service
sudo systemctl disable otelcol-sumo

# Remove package
sudo yum remove -y otelcol-sumo  # RPM-based
sudo apt-get remove -y otelcol-sumo  # DEB-based

# Remove configuration
sudo rm -rf /etc/otelcol-sumo/
```

### Windows

```powershell
# Stop service
Stop-Service -Name OtelcolSumo

# Uninstall via Control Panel or:
$app = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*OpenTelemetry*"}
$app.Uninstall()

# Or uninstall via package manager if installed that way
```

## Next Steps

After successful testing:

1. Review the [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
2. Customize the cookbook for your environment
3. Test on all target platforms
4. Submit pull requests for improvements

For production deployment, consider using:

- Chef Server for centralized management
- Encrypted Data Bags or Chef Vault for secure token storage
- Role-based configurations for different environments
