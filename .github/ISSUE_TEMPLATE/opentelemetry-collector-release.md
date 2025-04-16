---
name: OpenTelemetry Collector Release
about: The release checklist for the OpenTelemetry Collector
title: Create OpenTelemetry Collector Release vx.xxx.x
labels: ''
assignees: ''

---

# Basic Information

|                                                      |                   |
|------------------------------------------------------|-------------------|
| Release owner                                        | [name]            |
| New Collector versions                               | [Version Number]  |
| Current Agent versions                               | [Version Number]  |
| Jira filter to all the tickets to be part of Release | [link(update it)] |

# Pre-Release Checks
- [ ] Generate a final Release Candidate build
  -  [ ] Publish build number #ot-agent-release
- [ ] All UT/IT tests are green
  - [ ] https://github.com/SumoLogic/sumologic-otel-collector/actions
  - [ ] https://github.com/SumoLogic/sumologic-otel-collector-packaging/actions
- [ ] Trigger the OTCpkg coherence check. Link
  - [ ] Wait for test to complete and ensure there is no failure for the OTCPkg in the broken view Link
- [ ] Windows/Mac build is signed and notarized
- [ ] Security check?
- [ ] Any UI change required?

# Rollout Prep
- [ ] Release document

# QE Validations
- [ ] QE team sign off - [Owner name]
- [ ] Manual validation is completed
  - [ ] Bugs in the release
  - [ ] New feature in the release
- [ ] All OT jobs are green on RC build on Stag. Link
- [ ] All ST validation jobs are green on RC build. Link
- [ ] S3MWorkflow API jobs are green
- [ ] Validate on Mac UI/API/Install script
- [ ] Validate upgrade workflow with previous released version.
  - [ ] Validate manually till the time we automate it
- [ ] Load test- Only if there is a very major release and the team wants to run it.
- [ ] Check no test failures on channel #ot-agent-e2e-failures

# Publishing
- [ ] Packages promoted from release-candidates channel to stable in packagecloud
- [ ] latest_version set to previous release candidate version and upload to the release-candidates S3 bucket
- [ ] S3 path for version copied from release-candidates bucket to the stable bucket
- [ ] latest_version set to release version and upload to the stable S3 bucket
- [ ] Publish GitHub releases
  - [ ] [Collector](https://github.com/SumoLogic/sumologic-otel-collector/blob/main/docs/release.md#publish-github-release)
  - [ ] [Packaging](https://github.com/SumoLogic/sumologic-otel-collector-packaging/blob/main/docs/release.md#publish-github-release)
