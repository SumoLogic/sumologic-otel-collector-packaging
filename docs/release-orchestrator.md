# Releasing with Orchestrator

- [How to release](#how-to-release)
  - [Check end-to-end tests](#check-end-to-end-tests)
  - [Find the package build number](#find-the-package-build-number)
  - [Trigger the release orchestrator](#trigger-the-release-orchestrator)
  - [Publish GitHub releases](#publish-github-releases)

## How to release

### Check end-to-end tests

Check if the Sumo internal e2e tests are passing.

We can begin the process of creating a release once QE has given a thumbs up for
a given package version.

### Find the package build number

Each package has a build number and it's included in the package version & filename.
For example, if the package version that QE validates is 0.108.0-1790 then the
build number is **1790**.

This build number is all you need to trigger the release process!

### Trigger the release orchestrator

The [Release Orchestrator][release_orchestrator_workflow] workflow automates the
entire release process. It will automatically:

1. Find and validate all related workflow runs (collector, packaging, containers)
2. Create draft releases for all three repositories
3. Promote packaging release candidates to stable
4. Provide a summary with links to all releases

There are two methods to trigger the orchestrator:

#### Option 1 - Use the `gh` cli tool to trigger the release

Run the following command (replace `BUILD_NUMBER` with the build number from QE):

```shell
PAGER=""; BUILD_NUMBER="1790"; \
gh workflow run release-orchestrator.yml \
-R sumologic/sumologic-otel-collector-packaging -f "package_build_number=${BUILD_NUMBER}"
```

The status of running workflows can be viewed with the `gh run watch` command.
You will have to manually select the correct workflow run. The name of the run
should have a title similar to `Release Orchestrator for Build: 1790`. Once you
have selected the correct run the screen will periodically update to show the
status of the run's jobs.

#### Option 2 - Use the GitHub website to trigger the release

Navigate to the [Release Orchestrator][release_orchestrator_workflow] workflow in
GitHub Actions. Find and click the `Run workflow` button on the right-hand side
of the page. Enter the package build number (e.g., 1790) and click the green
`Run workflow` button.

The workflow will automatically discover the related workflow IDs and orchestrate
the entire release process across all three repositories.

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

- **Packaging workflow not found**: Verify the build number is correct and the
  packaging workflow completed successfully
- **Collector workflow ID not found**: Check the packaging workflow's display title
  contains `Build for Remote Workflow: <ID>`
- **Containers workflow not found**: Verify the containers workflow ran and references
  the collector workflow ID
- **Workflow timeout**: The orchestrator retries for 60 seconds. If it still fails,
  check the target repository's Actions page manually

If any step fails, you can complete the remaining steps manually using the
[manual release documentation](./release.md).

[collector_changelog]: https://github.com/SumoLogic/sumologic-otel-collector/blob/main/CHANGELOG.md
[collector_releases]: https://github.com/SumoLogic/sumologic-otel-collector/releases
[containers_releases]: https://github.com/SumoLogic/sumologic-otel-collector-containers/releases
[packaging_releases]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/releases
[post_release_workflow]: https://github.com/SumoLogic/sumologic-otel-collector/actions/workflows/post-release.yml
[release_orchestrator_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/release-orchestrator.yml
