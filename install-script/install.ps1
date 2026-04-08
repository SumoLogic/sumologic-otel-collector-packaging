using assembly System.Net.Http
using namespace System.Net.Http

param (
    # Version is used to override the version of otelcol-sumo to install.
    [string] $Version,

    # InstallationToken is used to pass a Sumo Logic installation token to
    # this script. The default value is set to the value of the
    # SUMOLOGIC_INSTALLATION_TOKEN environment variable.
    [string] $InstallationToken = $env:SUMOLOGIC_INSTALLATION_TOKEN,

    # Tags is used to specify a list of tags for the collector. Specified via a
    # hash table.
    # e.g. -Tags @{ tag1 = "foo" ; tag2 = "bar" }
    [Hashtable] $Tags,

    # InstallHostMetrics is used to install host metric collection.
    [bool] $InstallHostMetrics,

    # Fips is used to download a fips binary installer.
    [bool] $Fips,

    # Specifies wether or not remote management is enabled
    [bool] $RemotelyManaged,

    # Ephemeral option enabled
    [bool] $Ephemeral,

    # The Timezone option is used to specify the timezone of the collector.
    [string] $Timezone,

    # The CollectorName option is used to specify the name of the collector.
    [string] $CollectorName,

    # The Clobber option is used to specify whether to overwrite existing
    [bool] $Clobber,

    # The API URL used to communicate with the SumoLogic backend
    [string] $Api,

    # The OpAmp Endpoint used to communicate with the OpAmp backend
    [string] $OpAmpApi,

    # OverrideArch overrides the architecture detected by this script. This can
    # enable installation of x64 packages on an ARM64 system. The default value
    # is set to the value of the OVERRIDE_ARCH environment variable.
    [string] $OverrideArch = $env:OVERRIDE_ARCH,

    # PackagePath is the path on disk to the MSI package. It overrides
    # downloading of the package from the internet.
    [string] $PackagePath,

    # SkipArchDetection will disable the detection of the CPU architecture.
    # CPU architecture detection is slow. Using OverrideArch with this flag
    # improves the overall time it takes to execute this script.
    [bool] $SkipArchDetection,

    # S3Bucket is used to specify which S3 bucket to download the MSI package
    # from. The default value is set to the value of the S3_BUCKET environment
    # variable.
    [string] $S3Bucket = $env:S3_BUCKET,

    # S3Region is used to specify which S3 region to download the MSI package
    # from. The default value is set to the value of the S3_REGION environment
    # variable.
    [string] $S3Region = $env:S3_REGION,

    # UseWinget enables installation via Windows Package Manager (winget).
    # When set, the script will attempt to install using winget first.
    # If winget installation fails, it falls back to MSI.
    # Note: This flag only affects installation behavior. For upgrade and
    # uninstall operations, the script will attempt to use winget when available
    # and fall back to MSI if needed.
    [switch] $UseWinget,

    # Uninstall removes the Sumo Logic OpenTelemetry Collector from the system.
    # When uninstalling, the script attempts to use winget when available and
    # falls back to MSI if winget-based uninstallation is not possible.
    # Use with -Purge to also remove configuration and data files.
    [switch] $Uninstall,

    # Upgrade updates the collector to the latest version (or specified version).
    # When upgrading, the script attempts to use winget when available and
    # falls back to MSI if winget-based upgrade is not possible.
    [switch] $Upgrade,

    # Purge removes all configuration and data files when used with -Uninstall.
    [switch] $Purge
)

# If the environment variable SKIP_ARCH_DETECTION is set and is not
# equal to "0" then set $SkipArchDetection to $True.
if ($env:SKIP_ARCH_DETECTION -ne $null -and $env:SKIP_ARCH_DETECTION -ne "" -and $env:SKIP_ARCH_DETECTION -ne "0") {
    $SkipArchDetection = $True
}

if ($S3Bucket -eq "") {
    $S3Bucket = "sumologic-osc-stable"
}

if ($S3Region -eq "") {
    $S3Region = "us-west-2"
}

$S3URI = "https://" + $S3Bucket + ".s3." + $S3Region + ".amazonaws.com"
$CDN_URI = "https://download-otel.sumologic.com"

if ($S3Bucket -eq "sumologic-osc-stable") {
    $DOWNLOAD_URI = $CDN_URI
} else {
    $DOWNLOAD_URI = $S3URI
}

Write-Host "DOWNLOAD_URI = $DOWNLOAD_URI"

##
# Constants for winget and service management
##

# Winget package identifiers
$WINGET_PACKAGE_ID = "Sumologic.OtelcolSumo"
$WINGET_PACKAGE_ID_FIPS = "Sumologic.OtelcolSumo.Fips"

# Windows service name (from msi/wix/package.en-us.wxl)
$SERVICE_NAME = "OtelcolSumo"

# Windows paths for purge (based on WiX folders.wxs)
# CommonAppDataFolder\Sumo Logic\OpenTelemetry Collector
$COLLECTOR_DATA_ROOT = "$env:ProgramData\Sumo Logic\OpenTelemetry Collector"
# TODO: validate config dir
$CONFIG_DIRECTORY = "$COLLECTOR_DATA_ROOT\config"
$DATA_DIRECTORY = "$COLLECTOR_DATA_ROOT\data"


##
# Security tweaks
#
# This script requires TLS v1.2 or newer. Due to some versions of Windows not
# using TLS v1.2 or TLS v1.3 by default we must detect if it is enabled and
# attempt to enable it if not:
#
# 1. Determine if enabled security protocols contain an allowed security
#    protocol. If yes then do nothing.
# 2. Find which security protocols from the list of allowed protocols are
#    supported by the system. If none, return an error.
# 3. Enable the found security protocols.
##

# A list of secure protocols that this script supports. Ordered from
# most preferred to least preferred.
$allowedSecurityProtocols = @(
    "Tls13"
    "Tls12"
)

function Test-UsingAllowedProtocol {
    foreach ($protocol in $allowedSecurityProtocols) {
        $securityProtocol = [Net.ServicePointManager]::SecurityProtocol
        $securityProtocols = $securityProtocol.ToString().Split(",").Trim()
        if ($securityProtocols -contains $protocol) {
            return $true
        }
    }
    return $false
}

function Get-AvailableAllowedSecurityProtocols {
    $availableProtocols = @()

    foreach ($allowedProtocol in $allowedSecurityProtocols) {
        $definedProtocol = [Enum]::GetNames([Net.SecurityProtocolType]) -contains $allowedProtocol

        if ($definedProtocol) {
            $availableProtocols += $allowedProtocol
        }
    }

    return $availableProtocols
}

function Enable-SecurityProtocol {
    param (
        [Parameter(Position = 0, Mandatory = $true)]
        [Net.SecurityProtocolType] $protocol
    )

    [Net.ServicePointManager]::SecurityProtocol += $protocol
}

if (!(Test-UsingAllowedProtocol)) {
    $protocols = $allowedSecurityProtocols -join ", "
    Write-Warning "No allowed security protocols are enabled on this system. Allowed protocols: ${protocols}"
    Write-Warning "Detecting available security protocols..."

    $available = Get-AvailableAllowedSecurityProtocols
    if ($available.Count -eq 0) {
        Write-Error "No allowed security protocols are available on this system"
    }

    $availableStr = $available -join ", "
    Write-Warning "Detected allowed security protocols on this system: ${availableStr}"
    Write-Warning "Enabling security protocols: ${availableStr}"

    foreach ($name in $available) {
        Enable-SecurityProtocol([Net.SecurityProtocolType]$name)
    }
}

##
# Main functions
##

# A list of architectures can be found on Microsoft's website:
# https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-processor
Enum Architectures
{
    x86     = 0
    MIPS    = 1
    Alpha   = 2
    PowerPC = 3
    ia64    = 6
    x64     = 9
    ARM64   = 12
}

function Get-OSName
{
    Write-Host "Detecting OS type..."
    $platform = [System.Environment]::OSVersion.Platform

    switch ($platform)
    {
        "Win32NT" {}

        default {
            Write-Error "Unsupported OS type: ${platform}" -ErrorAction Stop
        }
    }

    return $platform
}

function Get-ArchName {
    param (
        [Parameter(Mandatory, Position=0)]
        [bool] $AllowUnsupported
    )

    Write-Host "Detecting architecture..."

    [int] $archId = (Get-CimInstance Win32_Processor)[0].Architecture

    $isDefinedArch = [enum]::IsDefined(([Architectures]), 12)
    if (!$isDefinedArch) {
        Write-Error "Unknown architecture id:`t${archId}" -ErrorAction Stop
    }

    [string] $archName = ""
    [Architectures] $arch = $archId

    switch ($arch)
    {
        x86     { $archName = "x86" }
        x64     { $archName = "x64" }
        MIPS    { $archName = "MIPS" }
        Alpha   { $archName = "Alpha" }
        PowerPC { $archName = "PowerPC" }
        ia64    { $archName = "ia64" }
        ARM64   { $archName = "ARM64" }

        default {
            Write-Error "Unsupported architecture:`t${arch}" -ErrorAction Stop
        }
    }

    # Only x64 is supported at the moment
    if (!($AllowUnsupported)) {
        if ($archName -ne "x64") {
            Write-Error "Unsupported architecture:`t${archName}" -ErrorAction Stop
        }
    }

    return $archName
}

function Get-InstalledApplicationVersion {
    $product = Get-CimInstance Win32_Product | Where-Object {
        $_.Name -eq "OpenTelemetry Collector" -and $_.Vendor -eq "Sumo Logic"
    }

    if ($product -eq $null) {
        return
    }

    $installLocation = $product.InstallLocation
    $binPath = "${installLocation}bin\otelcol-sumo.exe"

    if (!(Test-Path -Path $binPath -PathType Leaf)) {
        Write-Warning "Sumo Logic OpenTelemetry Collector is installed but otelcol-sumo.exe could not be found. Continuing as if it were not installed."
        return
    }

    $version = . $binPath --version | Out-String

    $versionRegex = '(\d)\.(\d+)\.(\d+)(.*(\d+))'
    $Matches = [Regex]::Matches($version, $versionRegex)
    $majorVersion = $Matches[0].Groups[1].Value
    $minorVersion = $Matches[0].Groups[2].Value
    $patchVersion = $Matches[0].Groups[3].Value
    $suffix = $Matches[0].Groups[4].Value
    $buildVersion = $Matches[0].Groups[5].Value

    return "${majorVersion}.${minorVersion}.${patchVersion}-sumo-${buildVersion}"
}

function Get-InstalledPackageVersion {
    $package = Get-Package -name "OpenTelemetry Collector" -EA Ignore

    if ($package -eq $null) {
        return
    }

    return $package.Version.Replace("-", ".")
}

function Get-LatestVersion {
    param (
        [Parameter(Mandatory, Position=1)]
        [HttpClient] $HttpClient
    )

    $URI = $DOWNLOAD_URI + "/latest_version"
    $request = [HttpRequestMessage]::new()
    $request.Method = "GET"
    $request.RequestURI = $URI

    Write-Host "Fetching latest version from: ${URI}"

    $response = $HttpClient.SendAsync($request).GetAwaiter().GetResult()
    if (!($response.IsSuccessStatusCode)) {
        $statusCode = [int]$response.StatusCode
        $reasonPhrase = $response.StatusCode.ToString()
        $errMsg = "${statusCode} ${reasonPhrase}"

        if ($response.Content -ne $null) {
            $content = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
            $errMsg += ": ${content}"
        }

        Write-Error $errMsg -ErrorAction Stop
    }

    $content = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    return $content -replace "`n","" -replace "`r",""
}

function Get-BinaryFromURI {
    param (
        [Parameter(Mandatory, Position=0)]
        [string] $URI,

        [Parameter(Mandatory, Position=1)]
        [string] $Path,

        [Parameter(Mandatory, Position=2)]
        [HttpClient] $HttpClient
    )

    if (Test-Path $Path) {
        Write-Host "${Path} already exists, removing..."
        Remove-Item $Path
    }

    Write-Host "Preparing to download ${URI}"
    $requestURI = [System.Uri]$URI
    $optReadHeaders = [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead
    $response = $HttpClient.GetAsync($requestURI, $optReadHeaders).GetAwaiter().GetResult()
    $responseMsg = $response.EnsureSuccessStatusCode()

    $httpStream = $response.Content.ReadAsStreamAsync().GetAwaiter().GetResult()
    $fileStream = [System.IO.FileStream]::new(
        $Path,
        [System.IO.FileMode]::Create,
        [System.IO.FileAccess]::Write
    )

    $copier = $httpStream.CopyToAsync($fileStream)
    Write-Host "Downloading ${requestURI}"
    $copier.Wait()
    $fileStream.Close()
    $httpStream.Close()

    Write-Host "Downloaded ${Path}"
}

##
# Winget and service management functions
##

function Test-WingetAvailable {
    <#
    .SYNOPSIS
        Check if winget is available on the system
    .OUTPUTS
        Boolean indicating if winget command is available
    #>
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function ConvertTo-MsiVersion {
    <#
    .SYNOPSIS
        Convert version string to MSI format (dots instead of dashes)
    .DESCRIPTION
        Converts version formats like "0.109.0-1800" to "0.109.0.1800"
        MSI uses the same format as winget (4-part dotted version).
    .PARAMETER Version
        The version string to convert
    .OUTPUTS
        Version string in MSI format (a.b.c.build)
    #>
    param (
        [Parameter(Mandatory)]
        [string] $Version
    )

    if ($Version -match '^\d+\.\d+\.\d+-\d+$') {
        # Convert dashed format to dotted MSI format
        return $Version -replace '-', '.'
    }
    if ($Version -match '^\d+\.\d+\.\d+\.\d+$') {
        # Already in valid MSI/winget format
        return $Version
    }
    throw "Invalid version format '$Version'. Expected 'X.Y.Z-BUILD' or 'X.Y.Z.BUILD'."
}

function ConvertTo-DownloadVersion {
    <#
    .SYNOPSIS
        Convert version string to download path format (dash before build number)
    .DESCRIPTION
        Converts version formats like "0.109.0.1800" to "0.109.0-1800"
        The download path on the CDN uses a dash to separate the build number.
    .PARAMETER Version
        The version string to convert
    .OUTPUTS
        Version string in download path format (a.b.c-build)
    #>
    param (
        [Parameter(Mandatory)]
        [string] $Version
    )

    if ($Version -match '^\d+\.\d+\.\d+-\d+$') {
        # Already in download path format
        return $Version
    }
    if ($Version -match '^(\d+\.\d+\.\d+)\.(\d+)$') {
        # Convert dotted format to dashed download path format
        return "$($Matches[1])-$($Matches[2])"
    }
    throw "Invalid version format '$Version'. Expected 'X.Y.Z-BUILD' or 'X.Y.Z.BUILD'."
}

function Stop-CollectorService {
    <#
    .SYNOPSIS
        Stop the OpenTelemetry Collector service if running
    #>

    $service = Get-Service -Name $SERVICE_NAME -ErrorAction SilentlyContinue

    if ($service -eq $null) {
        Write-Host "Service '$SERVICE_NAME' not found"
        return
    }

    if ($service.Status -eq 'Running') {
        Write-Host "Stopping service '$SERVICE_NAME'..."
        Stop-Service -Name $SERVICE_NAME -Force -ErrorAction SilentlyContinue

        # Wait for service to stop (max 60 seconds total)
        $timeout = 60
        $elapsed = 0
        while ((Get-Service -Name $SERVICE_NAME).Status -ne 'Stopped' -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 1
            $elapsed++
        }

        if ((Get-Service -Name $SERVICE_NAME).Status -eq 'Stopped') {
            Write-Host "Service stopped successfully"
        } else {
            $errorMessage = "Service '$SERVICE_NAME' did not stop within $timeout seconds. Aborting operation."
            Write-Error $errorMessage
            throw $errorMessage
        }
    } else {
        Write-Host "Service '$SERVICE_NAME' is not running"
    }
}

function Build-MsiProperties {
    <#
    .SYNOPSIS
        Build a hashtable of MSI properties from common installation parameters.
        Used by both the MSI and winget installation paths to avoid duplication.
    .PARAMETER Tags
        Tags hashtable
    .PARAMETER Api
        API URL
    .PARAMETER OpAmpApi
        OpAmp API URL
    .PARAMETER InstallHostMetrics
        Whether to install host metrics
    .PARAMETER RemotelyManaged
        Whether remotely managed
    .PARAMETER Ephemeral
        Whether ephemeral
    .PARAMETER Timezone
        Timezone setting
    .PARAMETER CollectorName
        Collector name
    .PARAMETER Clobber
        Whether to clobber
    .OUTPUTS
        Hashtable of MSI property key-value pairs
    #>
    param (
        [hashtable] $Tags,

        [string] $Api,

        [string] $OpAmpApi,

        [bool] $InstallHostMetrics,

        [bool] $RemotelyManaged,

        [bool] $Ephemeral,

        [string] $Timezone,

        [string] $CollectorName,

        [bool] $Clobber
    )

    $msiProps = @{}

    if ($Tags -ne $null -and $Tags.Count -gt 0) {
        [string[]] $tagStrs = @()
        $Tags.GetEnumerator().ForEach({
            $tagStrs += "$($_.Key)=$($_.Value)"
        })
        $msiProps["TAGS"] = $tagStrs -join ","
    }
    if ($Api.Length -gt 0) {
        $msiProps["API"] = $Api
    }

    [string[]] $addLocalFeatures = @()
    if ($InstallHostMetrics -eq $true) {
        $addLocalFeatures += "HOSTMETRICS"
    }
    if ($RemotelyManaged -eq $true) {
        $addLocalFeatures += "REMOTELYMANAGED"
        if ($OpAmpApi.Length -gt 0) {
            $msiProps["OPAMPAPI"] = $OpAmpApi
        }
    }
    if ($Ephemeral -eq $true) {
        $addLocalFeatures += "EPHEMERAL"
    }
    if ($Clobber -eq $true) {
        $addLocalFeatures += "CLOBBER"
    }
    if ($addLocalFeatures.Count -gt 0) {
        $msiProps["ADDLOCAL"] = $addLocalFeatures -join ","
    }

    if ($Timezone.Length -gt 0) {
        $msiProps["TIMEZONE"] = $Timezone
    }
    if ($CollectorName.Length -gt 0) {
        $msiProps["COLLECTORNAME"] = $CollectorName
    }

    return $msiProps
}

function Install-ViaWinget {
    <#
    .SYNOPSIS
        Install package via winget
    .PARAMETER PackageId
        The winget package identifier
    .PARAMETER Version
        Optional specific version to install (winget format: a.b.c.build)
    .PARAMETER InstallationToken
        The Sumo Logic installation token
    .PARAMETER MsiProperties
        Additional MSI properties to pass via --custom
    .OUTPUTS
        Boolean indicating success or failure
    #>
    param (
        [Parameter(Mandatory)]
        [string] $PackageId,

        [string] $Version,

        [string] $InstallationToken,

        [hashtable] $MsiProperties = @{}
    )

    $wingetArgs = @(
        "install"
        "--id", $PackageId
        "--exact"
        "--accept-package-agreements"
        "--accept-source-agreements"
        "--silent"
    )

    if ($Version -ne "" -and $Version -ne $null -and $Version -ne "True" -and $Version -ne "False") {
        $wingetArgs += @("--version", $Version)
    }

    # Build custom MSI properties string
    $customProps = @()
    if ($InstallationToken -ne "" -and $InstallationToken -ne $null) {
        $customProps += "INSTALLATIONTOKEN=$InstallationToken"
    }
    if ($MsiProperties -ne $null) {
        foreach ($key in $MsiProperties.Keys) {
            $value = $MsiProperties[$key]
            # Escape embedded double quotes to prevent command injection
            $value = $value -replace '"', '""'
            if ($value -match '\s') {
                $customProps += "$key=`"$value`""
            } else {
                $customProps += "$key=$value"
            }
        }
    }

    if ($customProps.Count -gt 0) {
        $customStr = $customProps -join " "
        $wingetArgs += @("--custom", $customStr)
    }

    Write-Host "Installing via winget: $PackageId"
    if ($Version) {
        Write-Host "Version: $Version"
    }
    # Write-Host "Running: winget"
    # ToDo: remove below log, re add above log after testing
    # Log a sanitized version of the command to avoid exposing INSTALLATIONTOKEN
    $logWingetArgs = $wingetArgs.Clone()
    for ($i = 0; $i -lt $logWingetArgs.Count; $i++) {
        if ($logWingetArgs[$i] -is [string]) {
            $logWingetArgs[$i] = $logWingetArgs[$i] -replace 'INSTALLATIONTOKEN=\S+', 'INSTALLATIONTOKEN=<redacted>'
        }
    }
    Write-Host "Running: winget $($logWingetArgs -join ' ')"

    # Capture output to prevent it from being included in function return value
    $null = & winget @wingetArgs
    $wingetExitCode = $LASTEXITCODE

    if ($wingetExitCode -ne 0) {
        Write-Warning "Winget installation failed with exit code: $wingetExitCode"
        return $false
    }

    return $true
}

function Update-ViaWinget {
    <#
    .SYNOPSIS
        Upgrade package via winget
    .PARAMETER PackageId
        The winget package identifier
    .PARAMETER Version
        Optional specific version to upgrade to (winget format: a.b.c.build)
    .OUTPUTS
        Boolean indicating success or failure
    #>
    param (
        [Parameter(Mandatory)]
        [string] $PackageId,

        [string] $Version
    )

    $wingetArgs = @(
        "upgrade"
        "--id", $PackageId
        "--exact"
        "--accept-package-agreements"
        "--accept-source-agreements"
        "--silent"
    )

    if ($Version -ne "" -and $Version -ne $null -and $Version -ne "True" -and $Version -ne "False") {
        $wingetArgs += @("--version", $Version)
    }

    Write-Host "Upgrading via winget: $PackageId"
    if ($Version) {
        Write-Host "Target version: $Version"
    }
    Write-Host "Running: winget $($wingetArgs -join ' ')"

    # Capture output to prevent it from being included in function return value
    $null = & winget @wingetArgs
    $wingetExitCode = $LASTEXITCODE

    if ($wingetExitCode -ne 0) {
        Write-Warning "Winget upgrade failed with exit code: $wingetExitCode"
        return $false
    }

    return $true
}

function Uninstall-ViaWinget {
    <#
    .SYNOPSIS
        Uninstall package via winget
    .PARAMETER PackageId
        The winget package identifier
    .OUTPUTS
        Boolean indicating success or failure
    #>
    param (
        [Parameter(Mandatory)]
        [string] $PackageId
    )

    $wingetArgs = @(
        "uninstall"
        "--id", $PackageId
        "--exact"
        "--accept-source-agreements"
        "--silent"
    )

    Write-Host "Uninstalling via winget: $PackageId"
    Write-Host "Running: winget $($wingetArgs -join ' ')"

    # Capture output to prevent it from being included in function return value
    $null = & winget @wingetArgs
    $wingetExitCode = $LASTEXITCODE

    if ($wingetExitCode -ne 0) {
        Write-Warning "Winget uninstallation failed with exit code: $wingetExitCode"
        return $false
    }

    return $true
}

function Uninstall-ViaMsi {
    <#
    .SYNOPSIS
        Uninstall package via Windows Package/MSI system
    .OUTPUTS
        Boolean indicating success or failure
    #>

    $package = Get-Package -Name "OpenTelemetry Collector" -ErrorAction SilentlyContinue

    if ($package -eq $null) {
        Write-Warning "Package 'OpenTelemetry Collector' not found"
        return $false
    }

    Write-Host "Uninstalling via MSI: OpenTelemetry Collector"

    try {
        $package | Uninstall-Package -Force -ErrorAction Stop
        return $true
    } catch {
        Write-Warning "MSI uninstallation failed: $_"
        return $false
    }
}

function Remove-CollectorData {
    <#
    .SYNOPSIS
        Remove all collector configuration and data (purge)
    #>

    $paths = @(
        $CONFIG_DIRECTORY
        $DATA_DIRECTORY
    )

    foreach ($path in $paths) {
        if (Test-Path $path) {
            Write-Host "Removing: $path"
            try {
                Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            } catch {
                Write-Warning "Failed to remove ${path}: $_"
            }
        }
    }

    # Remove parent directory if empty
    if (Test-Path $COLLECTOR_DATA_ROOT) {
        $remaining = Get-ChildItem -Path $COLLECTOR_DATA_ROOT -ErrorAction SilentlyContinue
        if ($remaining.Count -eq 0) {
            Write-Host "Removing empty directory: $COLLECTOR_DATA_ROOT"
            Remove-Item -Path $COLLECTOR_DATA_ROOT -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-ViaMsi {
    <#
    .SYNOPSIS
        Install or upgrade package via MSI
    .PARAMETER HttpClient
        The HTTP client for downloading
    .PARAMETER Version
        The version to install
    .PARAMETER ArchName
        The architecture name (x64, etc.)
    .PARAMETER Fips
        Whether to use FIPS binary
    .PARAMETER InstallationToken
        The installation token
    .PARAMETER Tags
        Tags hashtable
    .PARAMETER Api
        API URL
    .PARAMETER OpAmpApi
        OpAmp API URL
    .PARAMETER InstallHostMetrics
        Whether to install host metrics
    .PARAMETER RemotelyManaged
        Whether remotely managed
    .PARAMETER Ephemeral
        Whether ephemeral
    .PARAMETER Timezone
        Timezone setting
    .PARAMETER CollectorName
        Collector name
    .PARAMETER Clobber
        Whether to clobber
    .PARAMETER PackagePath
        Path to local MSI package
    #>
    param (
        [Parameter(Mandatory)]
        [HttpClient] $HttpClient,

        [Parameter(Mandatory)]
        [string] $Version,

        [Parameter(Mandatory)]
        [string] $ArchName,

        [bool] $Fips,

        [string] $InstallationToken,

        [hashtable] $Tags,

        [string] $Api,

        [string] $OpAmpApi,

        [bool] $InstallHostMetrics,

        [bool] $RemotelyManaged,

        [bool] $Ephemeral,

        [string] $Timezone,

        [string] $CollectorName,

        [bool] $Clobber,

        [string] $PackagePath
    )

    # Convert version to MSI format (dots instead of dashes)
    $msiVersion = ConvertTo-MsiVersion -Version $Version
    # Convert version to download path format (dashes instead of dots)
    $downloadVersion = ConvertTo-DownloadVersion -Version $Version

    # Add -fips to the msi filename if necessary
    $fipsSuffix = ""
    if ($Fips -eq $true) {
        Write-Host "Getting FIPS-compliant binary"
        $fipsSuffix = "-fips"
    }

    # Download MSI or install from provided path
    $msiLanguage = "en-US"
    $msiFileName = "otelcol-sumo_${msiVersion}_${msiLanguage}.${ArchName}${fipsSuffix}.msi"
    $msiURI = $DOWNLOAD_URI + "/" + $downloadVersion + "/" + $msiFileName

    if ($PackagePath.Length -gt 0) {
        # Convert Unix-style path (e.g., /d/a/path) to Windows format (D:\a\path)
        if ($PackagePath -match '^/([a-zA-Z])/(.*)$') {
            $msiPath = "$($matches[1]):\$($matches[2])" -replace '/', '\'
        } else {
            $msiPath = $PackagePath
        }
        Write-Host "Using package from: ${msiPath}"
    } else {
        $msiPath = "${env:TEMP}\${msiFileName}"
        Get-BinaryFromURI $msiURI -Path $msiPath -HttpClient $HttpClient
    }

    # Build MSI properties
    $props = Build-MsiProperties `
        -Tags $Tags -Api $Api -OpAmpApi $OpAmpApi `
        -InstallHostMetrics $InstallHostMetrics -RemotelyManaged $RemotelyManaged `
        -Ephemeral $Ephemeral -Timezone $Timezone -CollectorName $CollectorName `
        -Clobber $Clobber

    [string[]] $msiProperties = @()
    if ($InstallationToken.Length -gt 0) {
        $msiProperties += "INSTALLATIONTOKEN=${InstallationToken}"
    }
    foreach ($key in $props.Keys) {
        $value = $props[$key]
        # Escape embedded double quotes to prevent command injection
        $value = $value -replace '"', '""'
        if ($value -match '\s') {
            $msiProperties += "$key=`"$value`""
        } else {
            $msiProperties += "$key=$value"
        }
    }

    $msiArgs = @("/i", "`"$msiPath`"", "/passive", "REBOOT=ReallySuppress") + $msiProperties
    $sanitizedMsiArgs = $msiArgs | ForEach-Object {
        if ($_ -match '^(?i)INSTALLATIONTOKEN=') {
            'INSTALLATIONTOKEN=****'
        } else {
            $_
        }
    }
    
    # Stop service first
    try {
        Stop-CollectorService
    } catch {
        Write-Warning "Failed to stop the collector service before MSI install. Continuing with msiexec, which may still stop or upgrade the service as needed. Error: $($_.Exception.Message)"
    }

    Write-Host "Running: msiexec.exe $($sanitizedMsiArgs -join ' ')"
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -NoNewWindow -PassThru

    if ($process.ExitCode -eq 3010) {
        Write-Warning "Installation succeeded but requires reboot (exit code 3010)."
    }
    elseif ($process.ExitCode -ne 0) {
        $redactedMsiArgs = ($msiArgs -join ' ') -replace 'INSTALLATIONTOKEN=\S+', 'INSTALLATIONTOKEN=***'
        $errorMsg = @"
MSI installation failed with exit code: $($process.ExitCode)

Package: $msiPath
Command: msiexec.exe $redactedMsiArgs

Common exit codes:
- 1603: Fatal error during installation
- 1618: Another installation is already in progress
- 1619: This installation package could not be opened
- 1633: This installation package is not supported on this platform
- 1638: Another version of this product is already installed

Troubleshooting steps:
1. Check Windows Event Viewer (Application logs) for detailed error information
2. Review MSI installation logs in: $env:TEMP
3. Ensure you have administrator privileges
4. Verify no other installations are running
5. Check available disk space and system requirements

For more information, visit: https://docs.microsoft.com/en-us/windows/win32/msi/error-codes
"@
        Write-Error $errorMsg -ErrorAction Stop
    }
}

##
# Main code
##

try {
    # Validate parameter combinations
    if ($Purge -and -not $Uninstall) {
        Write-Error "-Purge can only be used with -Uninstall" -ErrorAction Stop
    }

    if ($Uninstall -and $Upgrade) {
        Write-Error "-Uninstall and -Upgrade cannot be used together" -ErrorAction Stop
    }

    # Determine winget package ID based on FIPS flag
    $wingetPackageId = if ($Fips) { $WINGET_PACKAGE_ID_FIPS } else { $WINGET_PACKAGE_ID }

    $handler = New-Object HttpClientHandler
    $handler.AllowAutoRedirect = $true

    $httpClient = New-Object System.Net.Http.HttpClient($handler)

    # Set timeout and user-agent before any requests are made.
    # HttpClient properties cannot be modified after the first request.
    $userAgentHeader = New-Object System.Net.Http.Headers.ProductInfoHeaderValue("otelcol-sumo-installer", "0.1")
    $httpClient.DefaultRequestHeaders.UserAgent.Add($userAgentHeader)
    $httpClient.Timeout = New-Object System.TimeSpan(0, 0, 30)

    # ========================================
    # Handle Uninstall
    # ========================================
    if ($Uninstall) {
        Write-Host "Uninstalling OpenTelemetry Collector..."

        # Stop service first
        Stop-CollectorService

        $uninstallSuccess = $false

        # Try winget first if available, then fall back to MSI
        if (Test-WingetAvailable) {
            Write-Host "Attempting uninstall via winget..."
            $uninstallSuccess = Uninstall-ViaWinget -PackageId $wingetPackageId

            if (-not $uninstallSuccess) {
                Write-Warning "Winget uninstall failed. Falling back to MSI uninstall..."
            }
        } else {
            Write-Host "Winget is not available on this system."
        }

        if (-not $uninstallSuccess) {
            Write-Host "Attempting uninstall via MSI..."
            $uninstallSuccess = Uninstall-ViaMsi
        }

        if (-not $uninstallSuccess) {
            Write-Error "Uninstallation failed" -ErrorAction Stop
        }

        if ($Purge) {
            Write-Host "Purging configuration and data..."
            Remove-CollectorData
        }

        Write-Host "Uninstallation complete"
        exit 0
    }

    if ($Version -eq "" -or $Version -eq $null -or $Version -eq "True" -or $Version -eq "False") {
        Write-Host "Getting latest version..."
        $Version = Get-LatestVersion -HttpClient $httpClient
    }

    # ========================================
    # Handle Upgrade
    # ========================================
    if ($Upgrade) {
        Write-Host "Upgrading OpenTelemetry Collector..."

        # Verify that the collector is currently installed
        $installedVersion = Get-InstalledPackageVersion
        if ($installedVersion -eq $null) {
            Write-Error "OpenTelemetry Collector is not installed. Use the install command instead of -Upgrade." -ErrorAction Stop
        }
        Write-Host "Currently installed version:`t${installedVersion}"

        # Stop service first
        Stop-CollectorService

        # Try winget first if available, then fall back to MSI
        if (Test-WingetAvailable) {
            Write-Host "Attempting upgrade via winget..."
            $wingetUpgradeVersion = if ($Version) { ConvertTo-MsiVersion -Version $Version } else { $null }
            $upgradeSuccess = Update-ViaWinget -PackageId $wingetPackageId -Version $wingetUpgradeVersion

            if ($upgradeSuccess) {
                Write-Host "Upgrade via winget successful"
                exit 0
            }

            Write-Warning "Winget upgrade failed. Falling back to MSI upgrade..."
        } else {
            Write-Host "Winget is not available on this system. Proceeding with MSI upgrade..."
        }

        # Fall through to MSI installation path below
        # MSI handles upgrades automatically via MajorUpgrade element
    }

    # ========================================
    # Handle Install (and MSI Upgrade fallback)
    # ========================================

    # Installation token is required for fresh install, but not for upgrade
    if (-not $Upgrade) {
        if ($InstallationToken -eq $null -or $InstallationToken -eq "") {
            Write-Error "Installation token has not been provided. Please set the SUMOLOGIC_INSTALLATION_TOKEN environment variable." -ErrorAction Stop
        }
    }

    $osName = Get-OSName
    Write-Host "Detected OS type:`t${osName}"

    if ($SkipArchDetection -eq $False) {
        $archName = Get-ArchName -AllowUnsupported ($OverrideArch -ne "")
        Write-Host "Detected architecture:`t${archName}"
    } else {
        if ($OverrideArch -eq "") {
            Write-Error "OverrideArch flag must be set when using SkipArchDetection" -ErrorAction Stop
        }
        Write-Host "Skipping architecture detection"
    }

    if ($OverrideArch -ne "") {
        $archName = $OverrideArch
        Write-Host "Architecture overridden:`t${archName}"
    }

    if ($Fips -eq $true) {
        if ($osName -ne "Win32NT" -or $archName -ne "x64") {
            Write-Error "Error: The FIPS-approved binary is only available for windows/amd64" -ErrorAction Stop
        }
    }

    Write-Host "Getting installed version..."
    $installedAppVersion = Get-InstalledApplicationVersion
    $installedAppVersionStr = "none"
    if ($installedAppVersion -ne $null) {
        $installedAppVersionStr = $installedAppVersion
    }
    $installedPackageVersion = Get-InstalledPackageVersion
    $installedPackageVersionStr = "none"
    if ($installedPackageVersion -ne $null) {
        $installedPackageVersionStr = $installedPackageVersion
    }
    Write-Host "Installed app version:`t${installedAppVersionStr}"
    Write-Host "Installed package version:`t${installedPackageVersionStr}"

    Write-Host "Package version to install:`t${Version}"

    # Check if otelcol is already in newest version (for non-upgrade installs)
    $msiVersion = ConvertTo-MsiVersion -Version $Version
    if (-not $Upgrade -and $installedPackageVersion -eq $msiVersion) {
        Write-Host "OpenTelemetry collector is already in newest (${msiVersion}) version"
        exit 0
    }

    # ========================================
    # Try winget installation if requested (only for fresh install, not upgrade)
    # ========================================
    if ($UseWinget -and -not $Upgrade) {
        if (-not (Test-WingetAvailable)) {
            Write-Warning "Winget is not available on this system. Falling back to MSI installation."
        } else {
            Write-Host "Attempting installation via winget..."

            # Build MSI properties for winget --custom
            $msiProps = Build-MsiProperties `
                -Tags $Tags -Api $Api -OpAmpApi $OpAmpApi `
                -InstallHostMetrics $InstallHostMetrics -RemotelyManaged $RemotelyManaged `
                -Ephemeral $Ephemeral -Timezone $Timezone -CollectorName $CollectorName `
                -Clobber $Clobber

            # Convert version to winget format (dots instead of dashes)
            $wingetVersion = ConvertTo-MsiVersion -Version $Version

            $wingetSuccess = Install-ViaWinget `
                -PackageId $wingetPackageId `
                -Version $wingetVersion `
                -InstallationToken $InstallationToken `
                -MsiProperties $msiProps

            if ($wingetSuccess) {
                Write-Host "Installation via winget successful"
                exit 0
            } else {
                Write-Warning "Winget installation failed (version may not be available). Falling back to MSI installation."
            }
        }
    }

    # ========================================
    # MSI Installation (or fallback from winget)
    # ========================================
    Write-Host "Installing via MSI..."

    Install-ViaMsi `
        -HttpClient $httpClient `
        -Version $Version `
        -ArchName $archName `
        -Fips $Fips `
        -InstallationToken $InstallationToken `
        -Tags $Tags `
        -Api $Api `
        -OpAmpApi $OpAmpApi `
        -InstallHostMetrics $InstallHostMetrics `
        -RemotelyManaged $RemotelyManaged `
        -Ephemeral $Ephemeral `
        -Timezone $Timezone `
        -CollectorName $CollectorName `
        -Clobber $Clobber `
        -PackagePath $PackagePath

    Write-Host "Installation successful"

} catch [HttpRequestException] {
    $errorMessage = if ($_.Exception.InnerException -ne $null) {
        $_.Exception.InnerException.Message
    } else {
        $_.Exception.Message
    }
    Write-Error $errorMessage -ErrorAction Stop
} catch {
    Write-Error $_.Exception.Message
    exit 1
}