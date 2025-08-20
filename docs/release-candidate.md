# Release Candidates

## Promote packages & artifacts

The repository packages and artifacts in Amazon S3 need to be promoted to make
them available to the public. Follow one of the two options to trigger the
promotion in GitHub Actions.

### Option 1 - Use the `gh` cli tool to trigger promotion

The promotion process can be triggered by using the following command (be sure
to replace `VERSION` with the version of the packages to promote).

```shell
PAGER=""; VERSION="0.124.0-2054"; \
gh workflow run promote-ci-build.yml \
-R sumologic/sumologic-otel-collector-packaging -f "version=${VERSION}"
```

The status of running workflows can be viewed with the `gh run watch` command.
You will have to manually select the correct workflow run. The name of the run
should have a title similiar to `Promote Release Candidate: x`). Once you
have selected the correct run the screen will periodically update to show the
status of the run's jobs.

#### Option 2 - Use the GitHub website to trigger promotion

Navigate to the [Promote CI build][promote_ci_build_workflow] workflow in
GitHub Actions. Find and click the `Run workflow` button on the right-hand side
of the page. Fill in the version of the packages to promote. Click the
`Run workflow` button to trigger the release.

![Triggering promotion][promote_0]

[promote_0]: ../images/promote_0.png
[promote_ci_build_workflow]: https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions/workflows/promote-ci-builds.yml
