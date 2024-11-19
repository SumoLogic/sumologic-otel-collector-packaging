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

    # The API URL used to communicate with the SumoLogic backend
    [string] $Api,

    # The OpAmp Endpoint used to communicate with the OpAmp backend
    [string] $OpAmpApi,

    # OverrideArch overrides the architecture detected by this script. This can
    # enable installation of x64 packages on an ARM64 system. The default value
    # is set to the value of the OVERRIDE_ARCH environment variable.
    [string] $OverrideArch = $env:OVERRIDE_ARCH,

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
    [string] $S3Region = $env:S3_REGION
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
        Write-Warning "Sumo Logic OpenTelemtry Collector is installed but otelcol-sumo.exe could not be found. Continuing as if it were not installed."
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

    $URI = $S3URI + "/latest_version"
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
# Main code
##

try {
    if ($InstallationToken -eq $null -or $InstallationToken -eq "") {
        Write-Error "Installation token has not been provided. Please set the SUMOLOGIC_INSTALLATION_TOKEN environment variable." -ErrorAction Stop
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
        Write-Host "Architecture overridden: `t${archName}"
    }

    $handler = New-Object HttpClientHandler
    $handler.AllowAutoRedirect = $true

    $httpClient = New-Object System.Net.Http.HttpClient($handler)
    $userAgentHeader = New-Object System.Net.Http.Headers.ProductInfoHeaderValue("otelcol-sumo-installer", "0.1")
    $httpClient.DefaultRequestHeaders.UserAgent.Add($userAgentHeader)

    # set http client timeout to 30 seconds
    $httpClient.Timeout = New-Object System.TimeSpan(0, 0, 30)

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

    # Use user's version if set, otherwise get latest version from API (or website)
    if ($Version -eq "") {
        Write-Host "Getting latest version..."
        $Version = Get-LatestVersion -HttpClient $httpClient
    }

    # versions have a dash before the build number, the Windows convention is a dot
    $msiVersion = $Version.Replace("-", ".")

    Write-Host "Package version to install:`t${Version}"

    # Check if otelcol is already in newest version
    if ($installedPackageVersion -eq $msiVersion) {
        Write-Host "OpenTelemetry collector is already in newest (${msiVersion}) version"
    }

    # Add -fips to the msi filename if necessary
    $fipsSuffix = ""
    if ($Fips -eq $true) {
        Write-Host "Getting FIPS-compliant binary"
        $fipsSuffix = "-fips"
    }

    # Download MSI
    $msiLanguage = "en-US"
    $msiFileName = "otelcol-sumo_${msiVersion}_${msiLanguage}.${archName}${fipsSuffix}.msi"
    $msiURI = $S3URI + "/" + $Version + "/" + $msiFileName
    $msiPath = "${env:TEMP}\${msiFileName}"
    Get-BinaryFromURI $msiURI -Path $msiPath -HttpClient $httpClient

    # Install MSI
    [string[]] $msiProperties = @()
    [string[]] $msiAddLocal = @()
    $msiProperties += "INSTALLATIONTOKEN=${InstallationToken}"
    if ($Tags.Count -gt 0) {
        [string[]] $tagStrs = @()
        $Tags.GetEnumerator().ForEach({
            $tagStrs += "$($_.Key)=$($_.Value)"
        })
        $tagsProperty = $tagStrs -Join ","
        $msiProperties += "TAGS=`"${tagsProperty}`""
    }
    if ($Api.Length -gt 0) {
        $msiProperties += "API=`"${Api}`""
    }
    if ($InstallHostMetrics -eq $true) {
        $msiAddLocal += "HOSTMETRICS"
    }
    if ($RemotelyManaged -eq $true) {
        $msiAddLocal += "REMOTELYMANAGED"
        if ($OpAmpApi.Length -gt 0) {
            $msiProperties += "OPAMPAPI=`"${OpAmpApi}`""
        }
    }
    if ($Ephemeral -eq $true) {
        $msiAddLocal += "EPHEMERAL"
    }
    if ($msiAddLocal.Count -gt 0) {
        $addLocalStr = $msiAddLocal -Join ","
        $msiProperties += "ADDLOCAL=${addLocalStr}"
    }
    msiexec.exe /i "$msiPath" /passive $msiProperties
} catch [HttpRequestException] {
    Write-Error $_.Exception.InnerException.Message -ErrorAction Stop
}

Write-Host "Installation successful"
