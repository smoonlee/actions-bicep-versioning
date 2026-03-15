# actions-bicep-versioning

Automated Bicep module version management with GitHub Actions.

## Workflows

### Bicep Validate

Runs on PRs targeting `main` that modify files under `infra/`. Performs `bicep build` and `bicep lint` to validate changes. Can also be triggered manually.

### Check AVM Module Updates

Runs weekly (Monday 08:00 UTC) or manually. Scans Bicep files for Azure Verified Module (AVM) references, checks the Microsoft Container Registry for newer versions, and opens a PR if updates are found.

### Dependabot

Keeps GitHub Actions versions up to date (e.g. `actions/checkout`, `peter-evans/create-pull-request`).

## Repository Setup

### Required: Allow GitHub Actions to create PRs

The **Check AVM Module Updates** workflow creates pull requests using the `GITHUB_TOKEN`. This requires a repo-level setting to be enabled:

1. Go to **Settings → Actions → General**
2. Scroll to **Workflow permissions**
3. Check **"Allow GitHub Actions to create and approve pull requests"**
4. Click **Save**

### Required: Branch protection

To block PRs from merging when Bicep validation fails:

1. Go to **Settings → Branches → Branch protection rules**
2. Click **Add rule** and set the branch name pattern to `main`
3. Enable **"Require status checks to pass before merging"**
4. Search for and add **"Bicep Build & Lint"** as a required status check
5. Click **Create** / **Save changes**

Without this rule, failed checks will show as red on the PR but the merge button will remain enabled. With it enabled, GitHub will block merging until all required checks pass.
