# Tasks

## 1. Fix auto-merge token for workflow-modifying PRs in org-infra

> **BLOCKED** — The original approach (`workflows: write` in the
> `permissions:` block) was invalidated. `workflows` is not a valid
> `GITHUB_TOKEN` permission scope (validated in org-infra PR #626 / CI
> run #35727551614). See design.md Decision 1 for alternative approaches
> under evaluation.

- [x] ~~1.1 In org-infra `ci_dependencies.yml`, add `workflows: write` to the `approve_dependabot_prs` job permissions block.~~ **INVALIDATED** — `workflows` is not a valid scope for `GITHUB_TOKEN`.
- [x] ~~1.2 Open PR to org-infra with title `fix(ci): add workflows permission for dependabot auto-merge`.~~ **INVALIDATED** — PR #626 was opened and failed actionlint; closed without merge.
- [ ] 1.3 Select an alternative approach from design.md Decision 1 and implement accordingly.

## 2. Update CODEOWNERS in complytime-demos

- [ ] 2.1 Remove the `EXPERIMENT` and `SCOPE` comment lines from the CODEOWNERS CI exemption block. Replace with finalized wording that reflects org-wide rollout. Verify: the exemption line `.github/workflows/ci_*.yml` remains unchanged and the file passes yamllint/megalinter.

## 3. Add CODEOWNERS exemption to consumer repositories

- [ ] 3.1 Add the CI consumer workflow exemption block to `complyctl/.github/CODEOWNERS`. Append after the existing `* @complytime/complytime-dev` line. Verify: file ends with `.github/workflows/ci_*.yml` (no owner) as the last pattern.
- [ ] 3.2 Add the CI consumer workflow exemption block to `complypack/.github/CODEOWNERS`. Append after the existing `* @complytime/complytime-dev` line. Verify: file ends with `.github/workflows/ci_*.yml` as the last pattern.
- [ ] 3.3 Add the CI consumer workflow exemption block to `complytime/.github/CODEOWNERS`. Append after the existing `* @complytime/architecture-advisory-council` line. Verify: file ends with `.github/workflows/ci_*.yml` as the last pattern.
- [ ] 3.4 Create `complytime-core/.github/CODEOWNERS` with the default owner `* @complytime/complytime-dev` and the CI exemption block. Verify: file has both the default owner and the exemption pattern.
- [ ] 3.5 Add the CI consumer workflow exemption block to `complytime-collector-components/.github/CODEOWNERS`. Append after the existing `* @complytime/complytime-dev` line. Verify: file ends with `.github/workflows/ci_*.yml` as the last pattern.
- [ ] 3.6 Add the CI consumer workflow exemption block to `complytime-policies/.github/CODEOWNERS`. Append after the existing `* @complytime/complytime-policies-approvers @complytime/complytime-dev` line. Verify: file ends with `.github/workflows/ci_*.yml` as the last pattern.
- [ ] 3.7 Add the CI consumer workflow exemption block to `complytime-providers/.github/CODEOWNERS`. Append after the existing provider-specific approver entries (which must remain last for their respective paths). The CI exemption must be the final entry. Verify: `.github/workflows/ci_*.yml` is the last pattern in the file and provider-specific paths still have their dedicated approvers.

## 4. Validation

- [ ] 4.1 After the org-infra release containing the auto-merge token fix is published, verify that the next dependabot PR bumping an org-infra reusable workflow in complytime-demos auto-merges without manual intervention. Verify: the merged PR shows automated merger (not a human).
