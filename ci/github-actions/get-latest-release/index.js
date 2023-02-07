const core = require('@actions/core');
const github = require('@actions/github');

async function run() {
  try {
    // GitHub Action inputs
    const token = core.getInput('token');
    const owner = core.getInput('owner');
    const repository = core.getInput('repository');

    const octokit = github.getOctokit(token);

    const iterator = octokit.paginate.iterator(octokit.rest.repos.listReleases, {
      owner: owner,
      repo: repository,
      per_page: 100,
    });

    for await (const { data: releases } of iterator) {
      for (const release of releases) {
        if (release.draft || release.prerelease) {
          console.log("Skipping draft/prerelease release: %s - %s", release.name, release.tag_name);
          continue;
        }

        console.log("Found release: %s - %s", release.name, release.tag_name)

        // GitHub Action outputs
        core.setOutput('id', release.id);
        core.setOutput('tag_name', release.tag_name);
        core.setOutput('name', release.name);
        core.setOutput('body', release.body);
        core.setOutput('created_at', release.created_at);
        core.setOutput('published_at', release.published_at);

        return;
      }
    }

    core.setFailed("No non-draft/prerelease releases were found");
  } catch (error) {
    core.setFailed(error.message);
  }
}

run()
