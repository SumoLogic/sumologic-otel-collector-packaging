# Delivery Pipeline

## Storage

The Sumo Logic OpenTelemetry packages & install scripts, referred to sometimes
as "builds", are uploaded to several providers including Amazon S3 &
Packagecloud.

### Amazon S3

Amazon S3 stores builds for all platforms. It serves as both a backup and a way
to serve the install scripts & non-Linux packages to the public.

#### Layout

##### latest_version

The Amazon S3 buckets contain a `latest_version` file in the root of the bucket.
This file contains the latest package version available in the bucket.

##### Version directory

Each build has a directory with the package version for its name. The directory
holds all of the packages & install scripts for that build.

#### Retention

Objects in the `ci-builds` channel are pruned after 30 days by the Lifecycle
configuration for the bucket.

### Packagecloud

Packagecloud provides APT & YUM repositories for Linux packages. These
repositories provide a simple, native way to upgrade the collector without the
install script.

#### Retention

Packages in the `ci-builds` channel are pruned after 30 days by the `Prune` job
in GitHub Actions.

## Channels & Build Once, Promote Many

A "channels" implementation exists to keep packages & artifacts separate through
the delivery pipeline. These channels exist in both Amazon S3 & Packagecloud.

The concept of "Build Once, Promote Many" ensures that a build installed by a
user is the same build that was tested by developers & QE. There is no concept
of "alpha", "beta", or "release candidate" builds that are compiled separately.

Builds are built in GitHub Actions and are uploaded to the `ci-builds` channel.
When a build is a potential release candidate, it can be promoted to the
`release-candidates` channel for further testing. If release candidate testing
succeeds, the release candidate can be promoted to the `stable` channel and any
final release steps should be followed.

The delivery pipeline channels:

### ci-builds

The `ci-builds` channel is where builds are first uploaded to. All successful
builds from CI end up here. Features, functionality, and stability can vary
greatly in this channel.

### release-candidates

The `release-candidates` channel stores any builds from the `ci-builds` channel
that have been marked as a potential release candidate. The QE team will run
additional testing against builds in this channel.

### stable

The `stable` channel is publicly accessible and stores the production builds.

## Manual Promotion Process

> [!CAUTION]
> It is advised to use the promotion process described in the
> [release candidate][release-candidate-docs] and [release][release-docs]
> documentation.

Perform the following steps to promote packages & artifacts from either the:

1. `ci-builds` channel to the `release-candidates` channel.

1. `release-candidates` channel to the `stable` channel.

> [!IMPORTANT]
> It is important to perform these steps in order.

### Update latest version in source channel

Each channel in Amazon S3 requires a `latest_version` file to point to a version
that exists in that channel. This `latest_version` file is used by the install
script to determine the latest available version on macOS and Windows systems.
As the version that is being promoted will no longer be available in the release
candidates channel, the `latest_version` file must first be updated to a
previously available version.

#### Determine previous version in source channel

Packagecloud promotion removes packages from the source repository where as
promotion in Amazon S3 does not. As a result the previous version should be
determined from Packagecloud.

##### Promoting from ci-builds

1. Browse to the [ci-builds repository][pc_ci_builds] on the Packagecloud
website.

1. Packages are listed by most recently uploaded. The previous version can be
found by scrolling through the list of packages until the version previous to
the version to be released is found. There will likely be several pages to
scroll through before finding the previous version. E.g. If the version being
promoted is `0.124.0-2054` the previous version in the source channel could be
`0.124.0-2030`.

##### Promoting from release-candidates

1. Browse to the [release-candidates repository][pc_release_candidates] on the
Packagecloud website.

1. Packages are listed by most recently uploaded. The previous version can be
found by scrolling through the list of packages until the version previous to
the version to be released is found. There will likely be several pages to
scroll through before finding the previous version. E.g. If the version being
promoted is `0.124.0-2054` the previous version in the source channel could be
`0.124.0-2030`.

#### Update the latest version file

Run the following commands to update the latest version file in the source
channel bucket. Be sure to change the version in the `echo` command to the
previous source channel version from the previous step.

##### Promoting from ci-builds

```shell
echo '0.124.0-2030' > latest_version
aws s3 cp latest_version s3://sumologic-osc-ci-builds/latest_version --content-type text/plain
```

##### Promoting from release-candidates

```shell
echo '0.124.0-2030' > latest_version
aws s3 cp latest_version s3://sumologic-osc-release-candidates/latest_version --content-type text/plain
```

### Promote the packages

1. Browse to the [ci-builds repository][pc_ci_builds] if promoting from the
`ci-builds` channel or the
[release-candidates repository][pc_release_candidates] if promoting from the
`release-candidates` channel.

1. Use the search bar at the top of the page to search for the version to
promote (e.g. `0.124.0-2054`). There should be around 4 pages of results.

1. Click the checkbox to select all packages on the page.

1. Click `promote`.

1. Select `sumologic/stable`.

1. Click `Promote X packages` where X is the number of packages being promoted.

1. Refresh the page and repeat the previous steps until there are no more
packages to left to promote.

### Promote the artifacts

Now that the new packages are available in the destination channel in
Packagecloud, the artifacts in the Amazon S3 bucket for the destination channel 
can be promoted. Run the following command, replacing the value for `VERSION`
with the version to be promoted:

#### Promoting to release-candidates

```shell
export VERSION="0.124.0-2054"
aws s3 cp --recursive "s3://sumologic-osc-ci-builds/${VERSION}/" "s3://sumologic-osc-release-candidates/${VERSION}/"
```

#### Promoting to stable

```shell
export VERSION="0.124.0-2054"
aws s3 cp --recursive "s3://sumologic-osc-release-candidates/${VERSION}/" "s3://sumologic-osc-stable/${VERSION}/"
```

### Update latest version in destination channel

All of the packages and artifacts have been promoted. It is now safe to update
the `latest_version` file in the bucket for the destination channel. Run the
following command, replacing the version in the `echo` command to the version to
be promoted:

#### Promoting to release-candidates

```shell
echo '0.124.0-2054' > latest_version
aws s3 cp latest_version s3://sumologic-osc-release-candidates/latest_version --content-type text/plain
```

#### Promoting to stable

```shell
echo '0.124.0-2054' > latest_version
aws s3 cp latest_version s3://sumologic-osc-stable/latest_version --content-type text/plain
```

[pc_ci_builds]: https://packagecloud.io/sumologic/ci-builds
[pc_release_candidates]: https://packagecloud.io/sumologic/release-candidates
[pc_stable]: https://packagecloud.io/sumologic/stable
[release-candidate-docs]: release-candidate.md
[release-docs]: release.md
