# Spec Delta

## Purpose

Self-contained Ansible playbook that demonstrates complyctl with the Ampel
provider, scanning a GitHub repository's branch protection rules against the
ampel-bp policy fetched from quay.io, with secure token handling suitable for
recorded demo sessions.

## ADDED Requirements

### Requirement: Token validation

The playbook SHALL read `GITHUB_TOKEN` from the Ansible controller's environment
using `lookup('env', 'GITHUB_TOKEN')`. The playbook SHALL fail immediately with a
clear instructional message if the token is not set, before any remote tasks
execute.

#### Scenario: Token is set

- **GIVEN** the user has exported `GITHUB_TOKEN` in their environment
- **WHEN** the playbook starts
- **THEN** the playbook proceeds to the setup phase

#### Scenario: Token is not set

- **GIVEN** `GITHUB_TOKEN` is not set in the controller's environment
- **WHEN** the playbook starts
- **THEN** the playbook fails with a message instructing the user how to set it
  (e.g., `export GITHUB_TOKEN=$(gh auth token)`)

#### Scenario: Token lacks required permissions

- **GIVEN** `GITHUB_TOKEN` is set but the token lacks `administration:read` scope
  (required for querying branch protection rules)
- **WHEN** the scan runs
- **THEN** the scan task output includes an error indicating insufficient
  permissions, and the playbook fails at the exit code check with a visible error
  message (the separate debug task displays the scan output before the failure
  check runs)

### Requirement: Token security

The playbook SHALL prevent `GITHUB_TOKEN` from appearing in any Ansible output,
including verbose (`-vvv`) mode. The token SHALL be passed to the remote task
solely via the `environment` directive with `no_log: true`. Scan results SHALL be
displayed in a separate task that does not have access to the token environment.

#### Scenario: Token not visible in playbook output

- **GIVEN** a playbook run with `-vvv` verbose output
- **WHEN** the playbook executes all tasks
- **THEN** the token value does not appear in any task output, debug message, or
  error message

#### Scenario: Scan results displayed without token

- **GIVEN** the scan has completed
- **WHEN** the results are displayed
- **THEN** the scan stdout is displayed via a separate debug task that does not
  reference the token variable

### Requirement: Package installation

The playbook SHALL install `complyctl` and `complytime-providers-ampel` via `dnf`
with state `latest`. The playbook SHALL install `snappy` and `ampel` CLI tools
via `go install` using version variables defined in `vars:` (defaulting to
`snappy_version: "v0.2.6"` and `ampel_version: "v1.3.6"`), overridable via `-e`
for users who want `@latest`. The playbook SHALL ensure `~/go/bin` is on `PATH`
for subsequent tasks using the `environment` directive with
`PATH: "{{ ansible_env.HOME }}/go/bin:{{ ansible_env.PATH }}"` on tasks that
invoke Go-installed tools (not via `.bashrc` modification, which does not affect
Ansible's non-login, non-interactive shell).

#### Scenario: Fresh VM with no complyctl installed

- **GIVEN** a Fedora VM provisioned via Vagrant with no complyctl installed
- **WHEN** the playbook runs
- **THEN** `complyctl`, the ampel provider, `snappy`, and `ampel` CLI are all
  installed and `complyctl providers` lists the ampel provider

#### Scenario: Tools already installed

- **GIVEN** a Fedora VM with packages already present
- **WHEN** the playbook runs
- **THEN** `dnf` ensures packages are at the latest version and `go install`
  re-fetches the specified version of snappy and ampel

#### Scenario: Go install failure

- **GIVEN** a Fedora VM where `go install` fails (network unavailable,
  incompatible Go version, or compilation error)
- **WHEN** the setup phase runs
- **THEN** the task fails with Go's native error message and the playbook stops
  (Ansible default error handling)

### Requirement: Workspace configuration

The playbook SHALL create the complyctl workspace directory at
`~/complyctl-demo-ampel` and a `complytime.yaml` configuration file inline. The
configuration SHALL reference the ampel branch-protection policy OCI artifact at
`quay.io/complytime/policies-ampel-branch-protection:latest` with policy ID
`ampel-bp`. The configuration SHALL include the ampel complypack OCI artifact at
`quay.io/complytime/complypack-ampel-branch-protection:latest` with ID
`ampel-bp-pack`, which provides the provider-specific policy files required by
`complyctl generate`. The configuration SHALL define a target `complytime-demos`
with variables `url: https://github.com/complytime/complytime-demos` and
`specs: builtin:github/branch-rules.yaml`.

> **Note**: The `:latest` OCI tag is used intentionally for demo simplicity.
> Signature verification of OCI artifacts is deferred as a non-goal (see
> design.md risk section). The `complyctl get` output displays the fetched
> artifact digest, providing an audit trail of what version was used.

#### Scenario: Workspace created from scratch

- **GIVEN** the setup phase has completed and no workspace directory exists
- **WHEN** the playbook creates the workspace
- **THEN** the directory is created with a valid `complytime.yaml` and
  `complyctl doctor` reports no blocking failures

#### Scenario: Workspace already exists from a previous run

- **GIVEN** the setup phase has completed and the workspace directory exists
  from a previous run
- **WHEN** the playbook creates the workspace
- **THEN** the configuration file is overwritten with the correct content and
  `complyctl doctor` reports no blocking failures

### Requirement: Policy fetching

The playbook SHALL run `complyctl get` to fetch the ampel-bp policy from quay.io
into the local cache before scanning.

#### Scenario: First run with empty cache

- **GIVEN** a configured workspace with a valid `complytime.yaml`
- **WHEN** `complyctl get` runs with no cached policies
- **THEN** the policy is downloaded and `complyctl list` shows `ampel-bp`

#### Scenario: Registry unavailable

- **GIVEN** a configured workspace with a valid `complytime.yaml`
- **WHEN** quay.io is unreachable or returns an error during `complyctl get`
- **THEN** the task fails with complyctl's native error message and the playbook
  stops (Ansible default error handling)

### Requirement: Assessment generation

The playbook SHALL run `complyctl generate --policy-id ampel-bp` to prepare
the Ampel assessment artifacts.

#### Scenario: Generate produces ampel artifacts

- **GIVEN** `complyctl get` has successfully fetched the ampel-bp policy
- **WHEN** `complyctl generate` runs
- **THEN** the command succeeds and the Ampel provider writes assessment
  artifacts to `.complytime/scan/ampel/` (the exact artifact structure is
  provider-specific and may vary by version)

### Requirement: Branch protection scan

The playbook SHALL run `complyctl scan complytime-demos --format pretty` with
`GITHUB_TOKEN` set in the task environment. The scan task SHALL use `register`
and `failed_when: false` to capture the exit code. A separate task SHALL display
`scan_result.stdout_lines`. Another separate task SHALL check the exit code:
exit code 0 or 1 is acceptable (1 indicates non-compliant findings were
detected), while exit code >1 indicates a scan error and SHALL cause the playbook
to fail. The scan SHALL target the `complytime-demos` GitHub repository. Scan
results SHALL be fetched to a local directory `./downloads_complyctl_github/`.

#### Scenario: Scan evaluates branch protection rules

- **GIVEN** a valid `GITHUB_TOKEN` with `administration:read` scope and a
  configured workspace with the ampel-bp policy fetched
- **WHEN** the scan runs
- **THEN** the scan completes without error (exit code 0 or 1) and the
  evaluation log contains at least one finding for branch protection controls
  on the `complytime-demos` repository

#### Scenario: Results fetched locally

- **GIVEN** the scan has completed
- **WHEN** the fetch phase runs
- **THEN** evaluation logs and reports are fetched to `./downloads_complyctl_github/` on
  the Ansible controller

### Requirement: Scan summary display

The playbook SHALL display the scan results to the user after fetching them.

#### Scenario: Summary shown after scan

- **GIVEN** the scan and fetch phases have completed
- **WHEN** the summary output runs
- **THEN** the playbook displays the scan output via `ansible.builtin.debug` and
  lists the local download directory path `./downloads_complyctl_github/`

### Requirement: Playbook idempotency

The playbook SHALL be designed for re-runnability. Running the playbook multiple
times in succession SHALL produce the same end state without errors.

#### Scenario: Playbook re-run after completion

- **GIVEN** a Fedora VM where the playbook has previously completed successfully
- **WHEN** the playbook runs again
- **THEN** all phases complete successfully and the end state matches the first
  run
