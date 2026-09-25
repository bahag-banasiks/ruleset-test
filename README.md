# GitHub Ruleset Bypass Test

This public repository tests the authorization model proposed for the
`sre-hybris` release workflow. It contains no application credentials. The test
GitHub App private key is stored only as an encrypted Actions secret.

## What This Proves

Terraform creates three repository rulesets:

1. `main-pull-request` requires one approval for `main`. The test App has
   `pull_request` bypass, so it must still create a PR but can merge without an
   approval.
2. `main-required-check` requires `Ruleset Test CI` on `main`. The App has no
   bypass here, proving it cannot skip CI.
3. `release-branch-lifecycle` restricts creation and deletion of
   `release/PPS_*`. Only the test App has `always` bypass.

The workflow runs explicit negative controls with `GITHUB_TOKEN` before trying
the same operation with the App token. A test passes only when the prohibited
operation fails and the authorized operation succeeds.

## One-Time GitHub App Setup

GitHub does not provide a Terraform resource for registering a GitHub App, so
this one step is performed in the GitHub UI:

1. Create a GitHub App owned by `bahag-banasiks`.
2. Disable webhooks.
3. Grant repository permissions:
   - Contents: Read and write
   - Pull requests: Read and write
   - Metadata: Read-only
4. Restrict installation to this account and install it only on
   `ruleset-test`.
5. Generate a private key.
6. Configure the repository without printing the key:

   ```bash
   gh variable set RULESET_TEST_APP_ID --body '<numeric-app-id>'
   gh secret set RULESET_TEST_APP_PRIVATE_KEY < /path/to/test-app.private-key.pem
   ```

The numeric App ID is not secret. Never commit the PEM file, an installation
token, a personal access token, or a Terraform state file.

## Apply The Rulesets

Commit and push this harness to `main` before applying Terraform. This ensures
the required-check workflow exists on the default branch before GitHub starts
requiring its result.

Use the authenticated GitHub CLI token only in the local process environment:

```bash
cd terraform
export GITHUB_TOKEN="$(gh auth token)"
export TF_VAR_test_app_id="$(gh variable get RULESET_TEST_APP_ID)"
terraform init
terraform plan
terraform apply
unset GITHUB_TOKEN TF_VAR_test_app_id
```

Review the plan before applying. The state is local and ignored by Git.

## Run The Tests

Run **Ruleset bypass test** from the Actions tab.

### `happy-path`

Expected evidence:

- App creates `release/PPS_TEST_<run-id>`.
- App opens a PR to `main`.
- `Ruleset Test CI` succeeds.
- `GITHUB_TOKEN` cannot merge the unapproved PR.
- The App merges the same unapproved PR.
- `GITHUB_TOKEN` cannot delete the protected release branch.
- The App deletes it.

### `failing-ci`

Expected evidence:

- `Ruleset Test CI` fails intentionally.
- The App cannot merge despite its PR-rule bypass.
- The App closes the test PR and deletes the release branch.

This is the important separation: the release App bypasses approvals, not CI.

## Teardown

```bash
cd terraform
export GITHUB_TOKEN="$(gh auth token)"
export TF_VAR_test_app_id="$(gh variable get RULESET_TEST_APP_ID)"
terraform destroy
unset GITHUB_TOKEN TF_VAR_test_app_id
```

After testing, uninstall/delete the test App, remove its private key, and delete
the repository secret.
