# Proposal

## Why

Dependabot PRs that bump org-infra reusable workflow version pins in
`ci_*.yml` files are failing to auto-merge despite the pipeline correctly
approving them and enabling auto-merge. Two independent blockers prevent
fully hands-off merging of these trusted, org-owned dependency updates:

1. The `approve_dependabot_prs` job in `ci_dependencies.yml` uses
   `GITHUB_TOKEN`, which cannot acquire `workflows` scope. GitHub
   immediately disables auto-merge with the error *"Tried to create or
   update workflow without `workflows` permission"* whenever the PR
   modifies a file under `.github/workflows/`. The `workflows` permission
   is only available to fine-grained PATs and GitHub App tokens -- it is
   not a valid scope in the workflow `permissions:` block (see design.md,
   Decision 1 for details).
2. Most org repositories still assign a code-owner team to `ci_*.yml`
   files, requiring a human code-owner approval that the bot cannot
   satisfy.

Both issues must be resolved together for auto-merge to work reliably.

## What Changes

- Provide the `approve_dependabot_prs` job with a token that has
  `workflows` scope, enabling auto-merge for PRs that modify workflow
  files. The original approach (adding `workflows: write` to the job
  `permissions:` block) was invalidated -- an alternative mechanism is
  needed (GitHub App token, `@dependabot merge` delegation, or other).
  See design.md Decision 1 for the evaluation.
- Standardize the CODEOWNERS pattern across all org repositories: exempt
  `ci_*.yml` files from code-owner review so the bot's approval is
  sufficient for these org-infra-managed files.
- Document the standard CODEOWNERS block and security rationale so
  maintainers can apply it consistently to each repository.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

None. This change affects CI pipeline permissions and repository
configuration files (CODEOWNERS). No application-level behavior is
introduced or modified. The change will set `skip_specs: true`.

## Impact

- **org-infra repository**: `ci_dependencies.yml` requires a change to
  the auto-merge step's token mechanism. The specific approach is under
  redesign (see design.md Decision 1). The workflow is synced to all
  consumer repos, so the chosen solution must work across all repos or
  degrade gracefully where prerequisites are not met.
- **All consumer repositories**: CODEOWNERS must be updated to include the
  `ci_*.yml` exemption block. Each repo requires a manual PR since
  CODEOWNERS contains repo-specific team assignments and is intentionally
  not synced from org-infra.
- **Security posture**: Whichever token mechanism is chosen, it will be
  scoped to a job that only executes for `dependabot[bot]` PRs. The PR
  content is authored by dependabot (SHA pin changes only). All existing
  safeguards remain: dependency review, OpenSSF Scorecard >= 5,
  major-version rejection, and required status checks.
