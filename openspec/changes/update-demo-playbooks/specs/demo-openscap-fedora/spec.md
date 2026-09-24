# Spec Delta

## Purpose

Self-contained Ansible playbook that demonstrates complyctl with the OpenSCAP
provider on a Fedora VM, from package installation through a full
break-scan-fix-rescan compliance cycle against CIS Fedora L1 Server policy.

## ADDED Requirements

### Requirement: Package installation

The playbook SHALL install `complyctl` and `complytime-providers-openscap` via
`dnf` with state `latest`, ensuring the most recent versions are always used.
The playbook SHALL NOT require any prior execution of `populate_*` development
playbooks or local repository clones.

#### Scenario: Fresh VM with no complyctl installed

- **GIVEN** a Fedora VM provisioned via Vagrant with no complyctl installed
- **WHEN** the playbook runs
- **THEN** `complyctl` and `complytime-providers-openscap` are installed from
  Fedora repositories and `complyctl version` succeeds

#### Scenario: VM with outdated packages

- **GIVEN** a Fedora VM with older versions of complyctl or providers installed
- **WHEN** the playbook runs
- **THEN** the packages are updated to the latest available versions

### Requirement: Workspace configuration

The playbook SHALL create the complyctl workspace directory at
`~/complyctl-demo` and a `complytime.yaml` configuration file inline (not from
a Jinja2 template). The
configuration SHALL reference the CIS Fedora L1 Server policy OCI artifact at
`quay.io/complytime/policies-cis-fedora-l1-server:latest` with policy ID
`cis-fedora-l1-server`. The configuration SHALL define a target `fedora-vm` with
the required variable `profile: cis_server_l1`.

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

The playbook SHALL run `complyctl get` to fetch the CIS Fedora L1 Server policy
from quay.io into the local cache before scanning.

#### Scenario: First run with empty cache

- **GIVEN** a configured workspace with a valid `complytime.yaml`
- **WHEN** `complyctl get` runs with no cached policies
- **THEN** the policy is downloaded and `complyctl list` shows
  `cis-fedora-l1-server`

#### Scenario: Registry unavailable

- **GIVEN** a configured workspace with a valid `complytime.yaml`
- **WHEN** quay.io is unreachable or returns an error during `complyctl get`
- **THEN** the task fails with complyctl's native error message and the playbook
  stops (Ansible default error handling)

### Requirement: Assessment generation

The playbook SHALL run `complyctl generate --policy-id cis-fedora-l1-server` to
create the XCCDF tailoring file from the fetched policy.

#### Scenario: Generate produces tailoring artifacts

- **GIVEN** `complyctl get` has successfully fetched the CIS Fedora L1 Server
  policy
- **WHEN** `complyctl generate` runs
- **THEN** the command succeeds and the OpenSCAP provider writes a tailoring file
  to `.complytime/scan/openscap/policy/tailoring.xml`

### Requirement: Deliberate rule violations for demo

The playbook SHALL deliberately break three system rules before the first scan to
demonstrate non-compliant findings:

- Remove the `firewalld` package (`package_firewalld_installed`)
- Remove the `Defaults logfile=` line from `/etc/sudoers`
  (`sudo_custom_logfile`)
- Set `UMASK` to `022` in `/etc/login.defs`
  (`accounts_umask_etc_login_defs`)

All modifications to `/etc/sudoers` SHALL use
`validate: /usr/sbin/visudo -cf %s` to prevent writing syntactically invalid
sudoers content.

#### Scenario: Rules are broken before first scan

- **GIVEN** the assessment generation has completed
- **WHEN** the prep phase completes
- **THEN** `firewalld` is not installed, `/etc/sudoers` has no `Defaults logfile`
  line, and `/etc/login.defs` has `UMASK 022`

### Requirement: First scan with failures

The playbook SHALL run `complyctl scan fedora-vm --format pretty` with elevated
privileges (`become: true`) after breaking the rules. The scan task SHALL use
`register` and `failed_when: false` to capture the exit code. A separate task
SHALL check the exit code: exit code 0 or 1 is acceptable (1 indicates
non-compliant findings were detected), while exit code >1 indicates a scan error
and SHALL cause the playbook to fail. The scan results SHALL be fetched to a
local directory `./downloads_scan1/`.

#### Scenario: Scan detects non-compliant rules

- **GIVEN** the three rules have been deliberately broken
- **WHEN** the scan runs
- **THEN** the scan completes without error (exit code 0 or 1) and the
  evaluation log (`evaluation-log-*.yaml`) contains entries with `result: fail`
  for rule IDs `package_firewalld_installed`, `sudo_custom_logfile`, and
  `accounts_umask_etc_login_defs`

#### Scenario: Results fetched locally

- **GIVEN** the first scan has completed
- **WHEN** the fetch phase runs
- **THEN** evaluation logs and reports are fetched to `./downloads_scan1/` on
  the Ansible controller

### Requirement: Rule remediation

The playbook SHALL fix the three broken rules:

- Install the `firewalld` package
- Add `Defaults logfile=/var/log/sudo.log` to `/etc/sudoers`
- Set `UMASK` to `027` in `/etc/login.defs`

All modifications to `/etc/sudoers` SHALL use
`validate: /usr/sbin/visudo -cf %s`.

#### Scenario: Rules are fixed before second scan

- **GIVEN** the first scan has completed and results have been fetched
- **WHEN** the fix phase completes
- **THEN** `firewalld` is installed, `/etc/sudoers` has the logfile directive,
  and `/etc/login.defs` has `UMASK 027`

### Requirement: Second scan after remediation

The playbook SHALL run `complyctl scan fedora-vm --format pretty` again with
elevated privileges after fixing the rules, using the same `register` +
`failed_when: false` + exit code check pattern as the first scan. The scan
results SHALL be fetched to a local directory `./downloads_scan2/`.

#### Scenario: Scan shows improvement after fixes

- **GIVEN** the three rules have been fixed
- **WHEN** the scan runs
- **THEN** the scan completes without error (exit code 0 or 1) and the three
  previously broken rule IDs no longer appear with `result: fail` in the
  evaluation log

#### Scenario: Results fetched locally

- **GIVEN** the second scan has completed
- **WHEN** the fetch phase runs
- **THEN** evaluation logs and reports are fetched to `./downloads_scan2/` on
  the Ansible controller

### Requirement: Before-and-after comparison

The playbook SHALL display output that allows the user to compare the results of
both scans, and SHALL inform the user where fetched files are located.

#### Scenario: Comparison output shown

- **GIVEN** both scan phases have completed and results have been fetched
- **WHEN** the comparison output runs
- **THEN** the playbook displays the `.complytime/` directory tree from both
  scans using `ansible.builtin.debug` tasks and lists the local download
  directory paths `./downloads_scan1/` and `./downloads_scan2/`

### Requirement: Playbook idempotency

The playbook SHALL be designed for re-runnability. Running the playbook multiple
times in succession SHALL produce the same end state without errors. The prep
phase resets the system to the expected broken state on each run, ensuring a
consistent starting point regardless of prior playbook execution or partial
failures.

#### Scenario: Playbook re-run after completion

- **GIVEN** a Fedora VM where the playbook has previously completed successfully
- **WHEN** the playbook runs again
- **THEN** all phases complete successfully and the end state matches the first
  run

#### Scenario: Playbook re-run after partial failure

- **GIVEN** a Fedora VM where a previous playbook run failed mid-execution
- **WHEN** the playbook runs again
- **THEN** the prep phase resets the system to the expected broken state and the
  full cycle completes successfully
