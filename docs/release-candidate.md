# Release Candidates

## Promote packages & artifacts

Perform the following steps to promote packages & artifacts from the `ci-builds`
channel to the `release-candidates` channel.

It is **important** to perform these steps **in order**.

### Update latest CI builds version

Each channel in Amazon S3 requires a `latest_version` file to point to a version
that exists in that channel. This `latest_version` file is used by the install
script to determine the latest available version on macOS and Windows systems.
As the version that is being promoted will no longer be available in the CI
builds channel, the `latest_version` file must first be updated to a
previously available version.

#### Determine previous CI builds version

Packagecloud promotion removes packages from the source repository where as
promotion in Amazon S3 does not. As a result the previous version should be
determined from Packagecloud.

1. Browse to the [ci-builds repository][pc_ci_builds] on the
Packagecloud website.

1. Packages are listed by most recently uploaded. The previous version can be
found by scrolling through the list of packages until the version previous to
the version to be released is found. There will likely be several pages to
scroll through before finding the previous version. E.g. If the version being
released is `0.124.0-2054` the previous CI build version could be
`0.124.0-2030`.

#### Update the latest version file

Run the following commands to update the latest version file in the CI builds
bucket. Be sure to change the version in the `echo` command to the previous
CI build version from the previous step.

```shell
echo '0.124.0-2030' > latest_version
aws s3 cp latest_version s3://sumologic-osc-ci-builds/latest_version --content-type text/plain
```

### Promote the packages

1. Browse to the [ci-builds repository][pc_ci_builds].

1. Use the search bar at the top of the page to search for the version to
promote (e.g. `0.124.0-2054`). There should be around 4 pages of results.

1. Click the checkbox to select all packages on the page.

1. Click `promote`.

1. Select `sumologic/release-candidates`.

1. Click `Promote X packages` where X is the number of packages being promoted.

1. Refresh the page and repeat the previous steps until there are no more
packages to left to promote.

### Promote the artifacts

Now that the new packages are available in the release candidates channel in
Packagecloud, the artifacts in the Amazon S3 CI builds bucket can be promoted.
Run the following command, replacing the value for `VERSION` with the version to
be promoted:

```shell
export VERSION="0.124.0-2054"
aws s3 cp --recursive "s3://sumologic-osc-ci-builds/${VERSION}/" "s3://sumologic-osc-release-candidates/${VERSION}/"
```

### Update latest release candidate version

All of the packages and artifacts have been promoted. It is now safe to update
the `latest_version` file in the release candidates channel. Run the following
command, replacing the version in the `echo` command to the version to be
promoted:

```shell
echo '0.124.0-2054' > latest_version
aws s3 cp latest_version s3://sumologic-osc-release-candidates/latest_version --content-type text/plain
```

[pc_ci_builds]: https://packagecloud.io/sumologic/ci-builds
