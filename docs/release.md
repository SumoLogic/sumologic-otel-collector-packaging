# Releasing

## Check end-to-end tests

Check if the Sumo internal e2e tests are passing.

We can begin the process of creating a release once the QE team has given a
thumbs up for a given package version.

## Perform Collector release steps

Perform the [collector release steps][collector_release] first to release the
Collector binaries.

## Promote packages & artifacts

The repository packages and artifacts in Amazon S3 need to be promoted to make
them available to the public. Follow one of the two options to trigger the
promotion in GitHub Actions.

### Option 1 - Use the `gh` cli tool to trigger promotion

The promotion process can be triggered by using the following command (be sure
to replace `VERSION` with the version of the packages to promote).

```shell
PAGER=""; VERSION="0.124.0-2054"; \
gh workflow run promote-release-candidate.yml \
-R sumologic/sumologic-otel-collector-packaging -f "version=${VERSION}"
```

The status of running workflows can be viewed with the `gh run watch` command.
You will have to manually select the correct workflow run. The name of the run
should have a title similiar to `Promote Release Candidate: x`). Once you
have selected the correct run the screen will periodically update to show the
status of the run's jobs.

#### Option 2 - Use the GitHub website to trigger promotion

Navigate to the [Promote release candidate][promote_rc_workflow] workflow in
GitHub Actions. Find and click the `Run workflow` button on the right-hand side
of the page. Fill in the version of the packages to promote. Click the
`Run workflow` button to trigger the release.

![Triggering promotion][promote_0]

## Create a GitHub Release

### Determine the Workflow Run ID to release

We can determine the Workflow Run ID to use for a release using the following steps.

#### Find the package build number

Each package has a build number and it's included in the package version &
filename. For example, if the package version that QE validates is 0.108.0-1790
then the build number is 1790.

#### Find the collector workflow run

We can find the workflow used to build the packages by using the package build
number.

The build number corresponds directly to the GitHub Run Number for a packaging
workflow run in GitHub Actions. Unfortunately, there does not currently appear to
be a way to reference a workflow run using the run number. Instead, we can use
one of two methods to find the workflow run:

##### Option 1 - Use the `gh` cli tool to find the workflow

```shell
PAGER=""; BUILD_NUMBER="1790"; \
gh run list -R sumologic/sumologic-otel-collector-packaging -s success \
-w build_packages.yml -L 200 -b main --json displayTitle,databaseId,number,url \
-q ".[] | select(.number == ${BUILD_NUMBER})"
```

This will output a number of fields, for example:

```json
{
  "databaseId": 11673248730,
  "displayTitle": "Build for Remote Workflow: 11672946742, Version: 0.108.0-sumo-1\n",
  "number": 1790,
  "url": "https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/runs/11673248730"
}
```

The number in the `databaseId` field is the ID for the workflow run that built
the packages.

The workflow run can be viewed by visiting the URL in the `url` field.

##### Option 2 - Search the GitHub website manually

Manually search for the run number on the
[Build packages workflow][build_workflow] page. Search for the build number
(e.g. 1790) until you find the corresponding workflow.

![Finding the packaging workflow run][release_0]

Once you've found the packaging workflow run, click it to navigate to the
details of the workflow run. The Workflow Run ID can be found in the last part
of the URL in the address bar:

![Finding the packaging workflow ID][release_1]

### Trigger the release

Now that we have the Workflow Run ID we can trigger a release. There are two
methods of doing this.

#### Option 1 - Use the `gh` cli tool to trigger the release

A release can be triggered by using the following command (be sure to replace
`WORKFLOW_ID` with the Workflow Run ID from the previous step):

```shell
PAGER=""; WORKFLOW_ID="11673248730"; \
gh workflow run build_packages.yml \
-R sumologic/sumologic-otel-collector-packaging -f workflow_id=${WORKFLOW_ID}
```

The status of running workflows can be viewed with the `gh run watch` command.
You will have to manually select the correct workflow run. The name of the run
should have a title similiar to `Publish Release for Workflow: x`). Once you
have selected the correct run the screen will periodically update to show the
status of the run's jobs.

#### Option 2 - Use the GitHub website to trigger the release

Navigate to the [Publish release][releases_workflow] workflow in GitHub Actions.
Find and click the `Run workflow` button on the right-hand side of the page.
Fill in the Workflow Run ID from the previous step. If the release should be
considered to be the latest version, click the checkbox for `Latest version`.
Click the `Run workflow` button to trigger the release.

![Triggering a release][release_2]

### Publish GitHub release

The GitHub release is created as draft by the
[releases](../.github/workflows/releases.yml) GitHub Action.

After the release draft is created, go to [GitHub releases](https://github.com/SumoLogic/sumologic-otel-collector-packaging/releases),
edit the release draft and fill in missing information:

- Specify versions for upstream OT core and contrib releases
- Copy and paste the Changelog entry for this release from [CHANGELOG.md][changelog]

After verifying that the release text and all links are good, publish the release.

[build_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/build_packages.yml?query=branch%3Amain
[changelog]: https://github.com/SumoLogic/sumologic-otel-collector/blob/main/CHANGELOG.md
[collector_release]: https://github.com/SumoLogic/sumologic-otel-collector/blob/main/docs/release.md
[promote_0]: ../images/promote_0.png
[promote_rc_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/promote-release-candidates.yml
[release_0]: ../images/release_0.png
[release_1]: ../images/release_1.png
[release_2]: ../images/release_2.png
[releases_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/releases.yml
