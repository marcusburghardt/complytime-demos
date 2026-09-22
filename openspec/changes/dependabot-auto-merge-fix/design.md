# Design

## Context

See proposal.md for motivation.

The org-infra `ci_dependencies.yml` is synced to all consumer repos via
the `sync-config.yml` mechanism. It contains three jobs:

1. `call_deps_reviewer` — runs `reusable_deps_reviewer.yml` (passive)
2. `call_dependabot_reviewer` — runs `reusable_dependabot_reviewer.yml`
   (passive)
3. `comment_on_dependabot_prs` — posts a structured review summary
4. `approve_dependabot_prs` — auto-approves and enables auto-merge

The `approve_dependabot_prs` job currently declares `contents: write`
and `pull-requests: write`. When it calls `gh pr merge --auto`, GitHub
attempts to merge a PR that modifies `.github/workflows/ci_*.yml` files.
This requires `workflows: write` on the token. Without it, GitHub
enables auto-merge momentarily, then immediately disables it with:

> "Tried to create or update workflow without `workflows` permission"

This was observed on PRs #90, #91, #92 in complytime-demos (Sep 14-15,
2026). PRs #88, #89, and #93 auto-merged successfully due to timing
(they completed before branch staleness forced re-evaluation).

CODEOWNERS is a separate, independent gate. Each repo manages its own
CODEOWNERS. The exemption pattern was introduced in complytime-demos
(`a51246b`, Jul 30, 2026) but not rolled out to other repositories.

## Goals / Non-Goals

**Goals:**

- Fix the `workflows` permission gap so auto-merge works reliably for
  org-infra reusable workflow version bumps.
- Provide a standard CODEOWNERS block that removes the code-owner gate
  for `ci_*.yml` files across all org repos.
- Remove the "EXPERIMENT" tag from the complytime-demos CODEOWNERS since
  the approach is being promoted to all repos.

**Non-Goals:**

- Auto-merging third-party (non-org-owned) dependency updates. These
  remain manual-merge-only.
- Syncing CODEOWNERS from org-infra. Each repo's CODEOWNERS is
  repo-specific due to different team structures.
- Changing branch protection settings. The existing "Require review from
  Code Owners" setting must stay enabled.

## Decisions

### Decision 1: Provide `workflows` scope for auto-merge

> **STATUS: INVALIDATED** — The original approach (adding
> `workflows: write` to the job `permissions:` block) does not work.
> `workflows` is not a valid `GITHUB_TOKEN` permission scope. This was
> validated in org-infra PR #626 / CI run #35727551614 where `actionlint
> v1.7.12` rejected the permission with:
>
> ```
> unknown permission scope "workflows". all available permission scopes
> are "actions", "artifact-metadata", "attestations", "checks",
> "contents", "deployments", "discussions", "id-token", "issues",
> "models", "packages", "pages", "pull-requests",
> "repository-projects", "security-events", "statuses"
> ```
>
> The `workflows` scope exists for fine-grained PATs and GitHub App
> tokens, but it cannot be granted to `GITHUB_TOKEN` via the workflow
> `permissions:` key. A different approach is required.

**Original choice (invalidated):** Add `workflows: write` to the
`approve_dependabot_prs` job permissions. This is not possible because
`workflows` is not in the set of valid `GITHUB_TOKEN` permission scopes.

**Alternative approaches under evaluation:**

1. *Delegate to dependabot via `@dependabot squash and merge`.* Instead
   of `gh pr merge --auto`, the workflow posts a PR comment that
   instructs dependabot to merge using its own credentials (a first-party
   GitHub App with inherent `workflows` scope). Zero secrets, zero setup,
   works in all synced repos. Unknowns: does dependabot's merge command
   wait for all checks? How does it handle stale branches or conflicts?

2. *GitHub App token (like `ci_renovate.yml`).* Create or reuse a GitHub
   App with `workflows: write`, use `actions/create-github-app-token` to
   mint a token, pass it to `gh pr merge --auto`. Proven pattern in the
   org (`ci_renovate.yml`, `sync_labels.yml`, `sync_org_repositories.yml`
   all use App tokens). Downside: `ci_dependencies.yml` is synced to all
   consumer repos — this would be the first synced workflow requiring App
   secrets. All consumer repos would need the App installed and org-level
   secrets configured.

3. *Graceful degradation.* Keep `gh pr merge --auto` with
   `GITHUB_TOKEN`. Detect whether the PR modifies `.github/workflows/`
   files and skip auto-merge for those (log "manual merge required").
   Works for non-workflow dependency PRs. Does not solve the original
   problem for org-infra version bumps.

4. *Hybrid: App token where available, fallback otherwise.* Check if App
   secrets exist at runtime. If yes, mint an App token for `gh pr merge
   --auto`. If not, use `GITHUB_TOKEN` with `continue-on-error`. Works
   perfectly where configured, degrades elsewhere. Adds complexity with
   secret-existence checks.

**Decision pending.** No approach has been selected. The CODEOWNERS work
(Decision 2) remains valid and independent of this decision.

### Decision 2: Standard CODEOWNERS exemption block

**Choice:** Every org repo adds a block at the end of CODEOWNERS that
assigns no owner to `ci_*.yml`:

```
.github/workflows/ci_*.yml
```

This entry with no owner listed removes the code-owner review
requirement for files matching that pattern. The "last match wins"
semantics mean this overrides the `*` catch-all.

**Why not sync CODEOWNERS from org-infra?** CODEOWNERS contains
repo-specific team assignments:
- `complytime-providers` has per-provider approvers
- `complytime-policies` has a separate policies-approvers team
- `complytime` uses `architecture-advisory-council`

Full-file sync would destroy these customizations. The sync script's
`dependabot` section already solved this for `dependabot.yml` with
common/override semantics, but extending that to CODEOWNERS would
require significant sync script changes for a one-time setup.

**Standard comment block:** Each repo should include a condensed version
of the explanatory comments (safeguards, scope) to document why the
exemption exists. The `EXPERIMENT` and `SCOPE` tags from
complytime-demos are no longer needed since this is being promoted
org-wide.

### Decision 3: Rollout order

**Choice:** Fix the permission in org-infra first, then update
CODEOWNERS in each repo. Both are needed for auto-merge to work, but
the permission fix is the prerequisite (a synced file, applied once)
while CODEOWNERS updates are per-repo.

**Rollout sequence:**

1. ~~PR to org-infra: add `workflows: write` to `ci_dependencies.yml`~~
   **BLOCKED** — original approach invalidated, see Decision 1.
   Replacement approach TBD.
2. New org-infra release (triggers dependabot bumps in all consumers)
3. Manual PR to each consumer repo: update CODEOWNERS
4. Update complytime-demos CODEOWNERS to remove EXPERIMENT tags

## Risks / Trade-offs

**[`workflows` scope requires a non-GITHUB_TOKEN credential]**
Whichever alternative approach is chosen (see Decision 1), granting
`workflows` scope means introducing either a GitHub App token or
delegating to dependabot's own credentials. The security mitigations
remain: the job only runs for `dependabot[bot]` PRs, the PR content is
authored by dependabot (SHA pin changes), and all branch protection
rules still apply.

**[Concurrent PR race condition]**
When org-infra publishes a release, dependabot opens 5-6 PRs
simultaneously (one per `ci_*.yml` file). After the first auto-merges,
the others become stale. Dependabot will rebase them, but the cycle
(rebase -> re-run CI -> auto-merge -> next PR becomes stale) can be
slow.
Mitigation: This is a known GitHub/dependabot limitation, not caused by
this change. If it becomes problematic, a future improvement could group
all workflow pins into a single dependabot PR using `groups:` in
`dependabot.yml`.

**[Repos without CODEOWNERS]**
`complytime-core` currently has no CODEOWNERS file. If "Require review
from Code Owners" is disabled in branch protection, the exemption is
unnecessary. If enabled, the absence of CODEOWNERS means no code-owner
gate exists for any file, so auto-merge already works without it.
Mitigation: Add CODEOWNERS anyway for consistency and to establish the
pattern before branch protection settings change.

## Affected Repositories

| Repository | Current CODEOWNERS | Action Needed |
|---|---|---|
| org-infra | None | Change auto-merge token mechanism (approach TBD, see Decision 1) |
| complytime-demos | Has exemption (experiment) | Remove EXPERIMENT tag |
| complyctl | `* @complytime/complytime-dev` | Add exemption block |
| complypack | `* @complytime/complytime-dev` | Add exemption block |
| complytime | `* @complytime/architecture-advisory-council` | Add exemption block |
| complytime-core | No CODEOWNERS | Create CODEOWNERS with exemption |
| complytime-collector-components | `* @complytime/complytime-dev` | Add exemption block |
| complytime-policies | `* @complytime/complytime-policies-approvers @complytime/complytime-dev` | Add exemption block |
| complytime-providers | Has provider-specific approvers | Add exemption block |
