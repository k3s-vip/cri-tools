## After release branch updates

You are the release manager who needs to update the master branch after release was created.

If asked to update the branch after release, follow the instructions and produce the release report.

### 1. Identify the release

- [ ] Ensure the working tree is clean (no uncommitted changes), switch to master branch, fetch all, and reset to `upstream/master`
- [ ] Identify the latest release by finding the latest tag like `vX.XX.0`
- [ ] Confirm with the user if this is the release that branch needs to be updated for

### 2. Make the branch consistent

- [ ] Create a working branch: `git checkout -b release-1.XX-after-release master`
- [ ] `dependencies.yaml`: update `cri-tools` version to the release version
- [ ] `README.md`: update `VERSION="vX.XX.0"` in install examples (both crictl and critest sections)
- [ ] Validate that the corresponding binary is available for download: `gh release view vX.XX.0 --repo kubernetes-sigs/cri-tools --json assets`
- [ ] Run `make verify` to check for issues

### 3. Create PR and fix CI failures

- [ ] Push the branch to origin
- [ ] Create a PR against `master` using `gh pr create` with `/kind cleanup` and `/release-note-none` tags in the body
- [ ] Wait for CI runs
- [ ] Review CI results and fix if needed

### 4. Create PR for Kubernetes repository

This step updates the cri-tools version in the main Kubernetes repository (similar to https://github.com/kubernetes/kubernetes/pull/138613).

Prerequisites: You need a fork of `kubernetes/kubernetes` or push access to create a branch.

- [ ] Clone or navigate to your fork of `kubernetes/kubernetes`
- [ ] Ensure the working tree is clean (no uncommitted changes), then create a branch: `git checkout -b cri-tools-1.XX upstream/master`
- [ ] Read `build/dependencies.yaml` and find the `crictl` entry — its `refPaths` list all files and match patterns that need updating
- [ ] Update `build/dependencies.yaml`: set `crictl` version to `1.XX.0`
- [ ] Update all files referenced in `refPaths` for the `crictl` dependency, updating version strings and sha512 hashes as needed
- [ ] Get sha512 hashes from the release checksum files (e.g., `crictl-vX.XX.0-linux-amd64.tar.gz.sha512`) available as release assets
- [ ] Push the branch and create a PR:

  ```
  gh pr create --repo kubernetes/kubernetes --base master \
    --title "Update cri-tools to vX.XX.0" \
    --body "#### What type of PR is this?
  /kind feature

  #### What this PR does / why we need it:
  Update cri-tools (crictl) to vX.XX.0.

  #### Which issue(s) this PR is related to:
  N/A

  #### Special notes for your reviewer:

  #### Does this PR introduce a user-facing change?
  \`\`\`release-note
  Updated cri-tools to vX.XX.0.
  \`\`\`"
  ```

- [ ] Wait for CI and address reviewer feedback
