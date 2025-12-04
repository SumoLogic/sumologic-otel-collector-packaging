# CI Build to Release Candidate Promotion

- [How to promote CI builds to release candidates](#how-to-promote-ci-to-release-candidates)
  - [Find the collector version](#find-the-collector-version)
  - [Trigger the CI-to-RC promotion workflow](#trigger-the-ci-to-rc-promotion-workflow)
  - [Verify promotion completion](#verify-promotion-completion)

## How to promote CI builds to release candidates

### Find the collector version

Each collector build has a version in the format X.Y.Z-BUILD. For example, **0.140.0-2502**.

The collector version corresponds to specific CI build workflows that need to be promoted
to release candidate status. You can find collector versions from:

1. The [Build packages workflow][build_packages_workflow] runs in the packaging repository
2. CI build artifacts in the ci repositories

### Trigger the CI-to-RC promotion workflow

The [CI-to-RC Promotion][ci_to_rc_workflow] workflow automates the promotion of
CI builds to release candidate status. It will:

1. Validate the collector version format and find all related workflow runs
2. Call packaging promotion workflow as a reusable workflow (ci → rc)
3. Call containers promotion workflow as a reusable workflow (ci → rc)
4. Provide a summary with the status of all promotion operations

**Execution Order** (sequential with automatic waiting):

1. Packaging promotion (ci → rc)
2. Containers promotion (ci → rc)

**How it Works**: The promotion workflow uses GitHub's `workflow_call` feature to invoke
promotion workflows across repositories as reusable workflows. This provides automatic
waiting for completion - no polling needed. Each workflow runs to completion before the
next one starts. If any workflow fails, the promotion stops and reports the failure.

There are two methods to trigger the promotion:

#### Option 1 - Use the `gh` cli tool to trigger promotion

Run the following command (replace `VERSION` with the collector version):

```shell
PAGER=""; VERSION="0.140.0-2502"; \
gh workflow run ci-to-rc-promotion.yml \
-R sumologic/sumologic-otel-collector-packaging -f "version=${VERSION}"
```

The status of running workflows can be viewed with the `gh run watch` command.
You will have to manually select the correct workflow run. The name of the run
should have a title similar to `CI-to-RC Promotion for Version: 0.140.0-2502`. Once you
have selected the correct run the screen will periodically update to show the
status of the run's jobs.

#### Option 2 - Use the GitHub website to trigger promotion

Navigate to the [CI-to-RC Promotion][ci_to_rc_workflow] workflow in
GitHub Actions. Find and click the `Run workflow` button on the right-hand side
of the page. Enter the collector version (e.g., 0.140.0-2502) and click the green
`Run workflow` button.

The workflow will discover the related workflow IDs and call promotion workflows across
both packaging and containers repositories as reusable workflows. Each workflow automatically
waits for completion before proceeding to the next step.

### Verify promotion completion

Once the promotion workflow completes successfully, it will provide a summary
with the status of all promotion operations. The summary will include:

- The collector version that was promoted
- The status of the packaging promotion (ci → rc)
- The status of the containers promotion (ci → rc)
- Links to the workflow runs for verification

The promoted artifacts will be available in:

1. **Packaging release-candidates**: Repository packages promoted from ci
2. **Containers release-candidates**: Container images promoted from ci

## Troubleshooting

If the promotion workflow fails at any step, check the workflow logs for details.
Common issues include:

- **Invalid version format**: Verify the collector version follows the X.Y.Z-BUILD format
  (e.g., 0.140.0-2502)
- **Collector workflow not found**: Verify the version is correct and the
  collector CI build workflow completed successfully
- **Containers workflow not found**: Verify the containers CI build workflow ran and references
  the collector workflow ID
- **Promotion failure**: If packaging or containers promotion fails, check the respective
  workflow logs for details (promote-ci-build.yml or release-candidates.yml)

If any step fails, the workflow will stop at the failed step and provide error details
in the workflow summary. You may need to investigate the specific failure and manually
retry or complete the promotion.

Use CI-to-RC promotion to make builds available for QE testing. Once QE validates
a release candidate, use the Release Orchestrator to create the final release.

[build_packages_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/build_packages.yml
[ci_to_rc_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/ci-to-rc-promotion.yml
