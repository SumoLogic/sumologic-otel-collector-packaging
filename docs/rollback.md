# Rolling Back a Release

This document describes how to revert packages in a specific channel
(release-candidates or stable) to the previous version when a problematic
release is discovered.

## Overview

The rollback process moves packages backward through the distribution channels
using GitHub Actions workflows. When you rollback a version:

1. Packages are moved from the source channel back to the destination channel in
   PackageCloud
2. The `latest_version` file in the source channel's S3 bucket is updated to the
   previous version (if rolling back the latest)
3. The `latest_version` file in the destination channel's S3 bucket is updated
   to reflect the new latest version

**Note:** This rollback mechanism only affects PackageCloud repositories and the
`latest_version` files in legacy S3 buckets (`sumologic-osc-*`). It does not
modify versioned artifacts already stored in S3 buckets.

## How It Works

### Distribution Channels

Packages flow through three channels in this order:

```
ci-builds → release-candidates → stable
```

**Rollback operations reverse this flow:**

- `release-candidates` can be rolled back to `ci-builds`
- `stable` can be rolled back to `release-candidates`

### Package Types

The following package types are affected by rollback:

**Linux:**
- DEB packages (amd64, arm64) - including FIPS variants
- RPM packages (x86_64, aarch64) - including FIPS variants

**macOS:**
- ProductBuild installers (.pkg) for Intel and Apple Silicon

**Windows:**
- MSI installers (amd64) - including FIPS variants

## When to Rollback

Consider rolling back when:

- A critical bug is discovered in a released version
- Security vulnerabilities are identified
- Installation failures occur on target platforms
- Package conflicts with system dependencies
- Configuration issues prevent the collector from starting
- Performance degradation is observed

## Rollback Procedures

### Rolling Back from stable to release-candidates

Use this when a problem is discovered in the stable channel and you need to
revert to the previous release candidate.

1. **Navigate to the workflow:**
   - Go to https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/rollback-stable.yml
   - Click "Run workflow"

2. **Enter the version to rollback:**
   - Input the full version string (e.g., `0.69.0-1234`)
   - Click "Run workflow"

3. **Monitor the workflow:**
   - The workflow will verify channel compatibility
   - Packages will be moved from `sumologic/stable` to `sumologic/release-candidates`
   - The `latest_version` file in `sumologic-osc-stable` will be updated if this was the latest version
   - The `latest_version` file in `sumologic-osc-release-candidates` will be updated to the new latest

4. **Verify the rollback:**
   ```bash
   # Check the latest version in release-candidates
   curl -s https://sumologic-osc-release-candidates.s3.amazonaws.com/latest_version

   # Check the latest version in stable
   curl -s https://sumologic-osc-stable.s3.amazonaws.com/latest_version

   # Verify packages in PackageCloud
   packagecloud list sumologic/stable otelcol-sumo
   packagecloud list sumologic/release-candidates otelcol-sumo
   ```

**Workflow Reference:** `.github/workflows/rollback-stable.yml:1`

### Rolling Back from release-candidates to ci-builds

Use this when a release candidate is found to be problematic during testing.

1. **Navigate to the workflow:**
   - Go to https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/rollback-release-candidate.yml
   - Click "Run workflow"

2. **Enter the version to rollback:**
   - Input the full version string (e.g., `0.69.0-1234`)
   - Click "Run workflow"

3. **Monitor the workflow:**
   - The workflow will verify channel compatibility
   - Packages will be moved from `sumologic/release-candidates` to `sumologic/ci-builds`
   - The `latest_version` file in `sumologic-osc-release-candidates` will be updated if this was the latest version
   - The `latest_version` file in `sumologic-osc-ci-builds` will be updated to the new latest

4. **Verify the rollback:**
   ```bash
   # Check the latest version in ci-builds
   curl -s https://sumologic-osc-ci-builds.s3.amazonaws.com/latest_version

   # Check the latest version in release-candidates
   curl -s https://sumologic-osc-release-candidates.s3.amazonaws.com/latest_version

   # Verify packages in PackageCloud
   packagecloud list sumologic/ci-builds otelcol-sumo
   packagecloud list sumologic/release-candidates otelcol-sumo
   ```

**Workflow Reference:** `.github/workflows/rollback-release-candidate.yml:1`

## Marking GitHub Release as Deprecated

When rolling back a stable release, you should also deprecate the corresponding
GitHub Release to warn users not to use the problematic version.

### Convert Release to Pre-Release

1. Navigate to the **Releases** page in the GitHub repository
2. Find the release that corresponds to the rolled-back version
3. Click **Edit** on the release
4. Check the **"Set as a pre-release"** checkbox
5. Click **"Update release"**

This will mark the release with a "Pre-release" badge, signaling to users that
it should not be used in production.

### Add Deprecation Warning

Update the release notes to include a clear deprecation warning at the top:

1. Edit the release notes
2. Add a warning section at the beginning explaining why the release was deprecated
3. Provide links to relevant issues or pull requests if applicable

Example deprecation notice:

```markdown
> **WARNING: This release has been deprecated**
>
> This release has been **deprecated** due to [brief description of the issue].
> Please use the previous stable release or wait for the next release.
>
> For more information, see [link to issue/PR].
```

**Real example** from [v0.133.0-2274](https://github.com/SumoLogic/sumologic-otel-collector-packaging/releases/tag/v0.133.0-2274):

```markdown
> This release has been **deprecated** due to upstream issues with the
> `gosnowflake` dependency, which required a downgrade as mentioned in
> open-telemetry/opentelemetry-collector-contrib#42607.
```
