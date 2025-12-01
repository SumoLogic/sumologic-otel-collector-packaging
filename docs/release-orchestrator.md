# Releasing with Orchestrator

- [How to release](#how-to-release)
  - [Check end-to-end tests](#check-end-to-end-tests)
  - [Find the package version](#find-the-package-version)
  - [Trigger the release orchestrator](#trigger-the-release-orchestrator)
  - [Publish GitHub releases](#publish-github-releases)

## How to release

### Check end-to-end tests

Check if the Sumo internal e2e tests are passing.

We can begin the process of creating a release once QE has given a thumbs up for
a given package version.

### Find the package version

Each package has a version that includes the build number in the format X.Y.Z-BUILD.
For example, if the package version that QE validates is **0.108.0-1790**, this is
the complete version you need to trigger the release process.

### Trigger the release orchestrator

The [Release Orchestrator][release_orchestrator_workflow] workflow automates the
entire release process. It will:

1. Validate the package version format and find all related workflow runs
2. Promote packaging release candidate to stable (waits for completion)
3. Trigger and wait for draft release workflows for all three repositories (collector, packaging, containers)
4. Provide a summary with links to all releases

**Execution Order** (sequential with completion waits):

1. Packaging RC→Stable promotion (10 min timeout, 30 sec polling)
2. Collector draft release (10 min timeout, 30 sec polling)
3. Packaging draft release (10 min timeout, 30 sec polling)
4. Containers draft release (10 min timeout, 30 sec polling)

**Note**: The orchestrator triggers workflows and waits for their completion before proceeding to the next step.
Each workflow has a 10-minute timeout with 30-second polling intervals. The orchestrator will fail if any workflow
doesn't complete within its timeout period.

There are two methods to trigger the orchestrator:

#### Option 1 - Use the `gh` cli tool to trigger the release

Run the following command (replace `VERSION` with the package version from QE):

```shell
PAGER=""; VERSION="0.108.0-1790"; \
gh workflow run release-orchestrator.yml \
-R sumologic/sumologic-otel-collector-packaging -f "package_version=${VERSION}"
```

The status of running workflows can be viewed with the `gh run watch` command.
You will have to manually select the correct workflow run. The name of the run
should have a title similar to `Release Orchestrator for Version: 0.108.0-1790`. Once you
have selected the correct run the screen will periodically update to show the
status of the run's jobs.

#### Option 2 - Use the GitHub website to trigger the release

Navigate to the [Release Orchestrator][release_orchestrator_workflow] workflow in
GitHub Actions. Find and click the `Run workflow` button on the right-hand side
of the page. Enter the package version (e.g., 0.108.0-1790) and click the green
`Run workflow` button.

The workflow will discover the related workflow IDs, trigger releases across
all three repositories, and wait for each to complete before proceeding to the next step.

### Publish GitHub releases

Once the orchestrator workflow completes successfully, it will provide a summary
with the status of all release operations and direct links to the draft releases.

The orchestrator creates draft releases for all three repositories:

1. **[Collector releases][collector_releases]**
2. **[Packaging releases][packaging_releases]**
3. **[Containers releases][containers_releases]**

#### Publishing order

⚠️ **IMPORTANT: Releases must be published in the following order:**

1. **Publish the [Collector Release][collector_releases] FIRST**
   - Edit the draft release and add the following information:
     - Specify versions for upstream OT core and contrib releases
     - Copy and paste the Changelog entry for this release from [CHANGELOG.md][collector_changelog]
   - After verifying that the release text and all links are correct, publish the release
   - Publishing this release will automatically trigger the [post-release workflow][post_release_workflow]
     which creates the necessary package tags

2. **Verify the [post-release workflow][post_release_workflow] completed successfully**
   - Ensure the workflow created the required package tags (e.g., `v0.108.0-1790`)
   - These tags are needed for the packaging and containers releases

3. **Publish the [Packaging Release][packaging_releases]**
   - Review the draft release, verify all artifacts are attached, and publish it

4. **Publish the [Containers Release][containers_releases]**
   - Review the draft release and publish it

The orchestrator workflow summary will provide direct links to all releases and
their current status.

## Troubleshooting

If the orchestrator workflow fails at any step, check the workflow logs for details.
Common issues include:

- **Invalid version format**: Verify the package version follows the X.Y.Z-BUILD format
  (e.g., 0.108.0-1790)
- **Packaging workflow not found**: Verify the version is correct and the
  packaging workflow completed successfully
- **Collector workflow ID not found**: Check the packaging workflow's display title
  contains `Build for Remote Workflow: <ID>`
- **Containers workflow not found**: Verify the containers workflow ran and references
  the collector workflow ID
- **Promotion failure**: If packaging promotion fails, check the promote-release-candidate
  workflow logs for details
- **Workflow timeout**: If any workflow exceeds the 10-minute timeout, check that workflow's
  logs in its respective repository. You may need to complete remaining steps manually.

If any step fails, you can complete the remaining steps manually using the
[manual release documentation](./release.md).

[collector_changelog]: https://github.com/SumoLogic/sumologic-otel-collector/blob/main/CHANGELOG.md
[collector_releases]: https://github.com/SumoLogic/sumologic-otel-collector/releases
[containers_releases]: https://github.com/SumoLogic/sumologic-otel-collector-containers/releases
[packaging_releases]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/releases
[post_release_workflow]: https://github.com/SumoLogic/sumologic-otel-collector/actions/workflows/post-release.yml
[release_orchestrator_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/release-orchestrator.yml
