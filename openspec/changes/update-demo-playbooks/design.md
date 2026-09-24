# Design

## Context

See proposal.md for motivation. The key constraints shaping this design:

- complyctl v1.0.0 and complytime-providers v0.2.1 are official Fedora packages
  available via `dnf install`.
- The `complytime-providers-openscap` RPM pulls in `openscap-scanner` and
  `scap-security-guide` as dependencies. The Vagrantfile also installs these at
  boot.
- The `complytime-providers-ampel` RPM does NOT pull in `snappy` or `ampel` CLI
  tools (not yet packaged in Fedora). These must be installed via `go install`.
  The Vagrantfile installs `golang` at boot.
- CIS Fedora L1 Server policies are published at
  `quay.io/complytime/policies-cis-fedora-l1-server:latest`.
- Ampel branch-protection policies are published at
  `quay.io/complytime/policies-ampel-branch-protection:latest`.
- The OpenSCAP provider requires one target variable: `profile` (SSG profile
  short name). The datastream is auto-detected from `/etc/os-release`.
- The Ampel provider requires two target variables: `url` and `specs`. It also
  reads `GITHUB_TOKEN` from the environment for GitHub API access.
- `complyctl scan` with the OpenSCAP provider requires `sudo` (system resource
  access). The Ampel provider does not.
- The existing `populate_*` playbooks and `complytime.yaml.j2` template remain
  available for development workflows and are not modified by this change.

## Goals / Non-Goals

**Goals:**

- Each demo playbook is fully self-contained: install, configure, fetch, scan.
- No dependency on local repository clones or prior playbook execution.
- `GITHUB_TOKEN` handling is safe for recorded sessions.
- Playbooks use RPM-installed `complyctl` (bare command, no path prefix).
- Playbooks pin `go install` tool versions in `vars:` for reproducibility, with `-e` override for `@latest`.

**Non-Goals:**

- Signature verification of OCI artifacts (adds complexity, can be layered later).
- ~~Complypack usage~~: Now required for the ampel provider. The complypack OCI
  artifact provides provider-specific policy files that `complyctl generate`
  needs to produce scan artifacts.
- OPA provider demo (no published OPA policy on quay.io yet).
- Changes to the Vagrantfile or existing development playbooks.
- Centralized variables across demo playbooks (each is self-contained by design).

## Decisions

### D1: Inline `complytime.yaml` instead of shared template

**Choice**: Each playbook creates its own `complytime.yaml` using
`ansible.builtin.copy` with `content:` rather than the existing
`complytime.yaml.j2` Jinja2 template.

**Alternatives considered**:
- Extend `complytime.yaml.j2` with conditionals for both policy types: Adds
  complexity to the template, couples the demo and dev workflows, and the
  template would need new variables that only apply to one scenario.
- Create two new templates (`complytime-openscap.yaml.j2`,
  `complytime-ampel.yaml.j2`): Unnecessary indirection for 5-10 lines of YAML.

**Rationale**: The configuration for each demo is small (under 10 lines) and
specific to its scenario. Inline content makes each playbook self-contained
and readable without jumping to a template file. The existing template remains
available for the dev workflows.

### D2: Pinned versions for snappy and ampel CLI tools

**Choice**: Use `go install ...@<version>` with version variables in `vars:`
(defaulting to `snappy@v0.2.6`, `ampel@v1.3.6`), matching the established
pattern in `populate_complyctl_dev_binaries.yml`. Users can override with
`-e snappy_version=latest -e ampel_version=latest`.

**Alternatives considered**:
- Always use `@latest`: Simple but non-reproducible. A breaking change between
  demo preparation and delivery could fail live with no rollback path.
- Query GitHub API for latest release tag: Over-engineering for a demo
  environment.

**Rationale**: Pinned versions provide reproducibility by default, which is
critical for a demo environment where reliability matters most. The `-e` override
provides an escape hatch for users who want the latest. Version variables are
defined in `vars:` (single source of truth) rather than hardcoded inline.

### D3: Token passed via controller environment variable

**Choice**: Read `GITHUB_TOKEN` from the Ansible controller's environment using
`lookup('env', 'GITHUB_TOKEN')` and pass it to the remote scan task via the
`environment:` directive with `no_log: true`.

**Alternatives considered**:
- `vars_prompt` with `private: true`: Masks input but the prompt text is still
  visible in recordings. Requires interactive execution, preventing CI use.
- `-e github_token=ghp_...` on the command line: Visible in shell history and
  process list. High leakage risk.
- Ansible vault file: Encrypted at rest but awkward for ad-hoc demos. Requires
  a vault password.
- Read from a file on the VM: Requires manual file creation step, easy to forget
  cleanup, risk of committing the file.

**Rationale**: The controller-side environment variable is invisible in playbook
output (Ansible does not log `lookup('env')` values). Combined with
`no_log: true` on the scan task, the token never appears in any output including
verbose mode. The presenter sets the variable before recording
(`export GITHUB_TOKEN=$(gh auth token)`) and it is never stored on disk.
A separate debug task displays scan results safely since `stdout_lines` contains
only the compliance report.

### D4: Separate display task for scan results

**Choice**: The Ampel scan task uses `no_log: true` and `register:`. A separate
`debug` task displays `scan_result.stdout_lines`.

**Alternatives considered**:
- Single task without `no_log`: Would expose the `GITHUB_TOKEN` environment
  variable in verbose output.
- Redirect scan output to a file and display the file: Adds unnecessary file I/O.

**Rationale**: Ansible's `no_log: true` suppresses all task details including
the `environment` block. By registering the result and displaying it in a
separate task that has no access to the token, the scan output is visible while
the token remains hidden.

### D5: Playbooks install their own dependencies

**Choice**: Each playbook starts with `dnf install` tasks (with `become: true`)
to ensure required packages are present and up to date.

**Alternatives considered**:
- Add packages to the Vagrantfile: Would install packages at VM creation time,
  but the Vagrantfile is shared across all use cases and users might not run
  both demos.
- Document installation as a manual prerequisite: Easy to miss, especially for
  new users.

**Rationale**: Self-contained playbooks that install their own dependencies
demonstrate the real user workflow (the first thing a user does is install the
tools) and ensure the demo always works regardless of VM state.

### D6: Keep the filename `demo_complyctl_fedora.yml`

**Choice**: Rewrite the existing file in place instead of renaming it.

**Alternatives considered**:
- Rename to `demo_openscap_fedora.yml`: More descriptive but breaks any existing
  references, bookmarks, or muscle memory.

**Rationale**: The file already exists and is referenced in the README. Keeping
the name avoids unnecessary churn and preserves continuity with prior
documentation.

## Risks / Trade-offs

- **[Risk] Go tool version drift**: The playbook pins `snappy` and `ampel` to
  specific versions (`v0.2.6` and `v1.3.6` respectively, matching the existing
  `populate_complyctl_dev_binaries.yml` pattern) with an `-e` override for users
  who want `@latest`. This balances reproducibility with flexibility. If a new
  version is needed, the user overrides via `-e snappy_version=latest`.

- **[Risk] OCI artifact availability**: The demos depend on quay.io availability.
  If the registry is down, `complyctl get` fails. Mitigation: `complyctl get`
  reports clear errors. The user can retry later. This is the same dependency any
  real user would have.

- **[Risk] CIS rules may change between SSG versions**: The three rules used for
  the break-scan-fix cycle (`package_firewalld_installed`,
  `sudo_custom_logfile`, `accounts_umask_etc_login_defs`) could be renamed or
  removed in a future `scap-security-guide` update. Mitigation: These are
  well-established CIS controls unlikely to change. If they do, the scan output
  will make it obvious which rules to update.

- **[Risk] `GITHUB_TOKEN` with insufficient permissions**: A fine-grained token
  without `administration:read` scope cannot query branch protection rules.
  Mitigation: The playbook should provide clear guidance on required token scopes
  in the failure message.

- **[Trade-off] No signature verification**: Skipping OCI signature verification
  simplifies the demos but does not demonstrate the full supply chain security
  workflow. This can be added as a follow-up.

- **[Trade-off] No complypack usage**: The ampel provider can use complypacks for
  granular policy files, but this demo uses the simpler direct policy approach.
  Complypack integration can be added later.

### D7: Scan exit code handling

**Choice**: Both playbooks use `register` + `failed_when: false` on `complyctl
scan` tasks, followed by a separate task that fails if `scan_result.rc > 1`.
Exit code 0 means the scan passed; exit code 1 means non-compliant findings
were detected (expected in the OpenSCAP demo's first scan); exit code >1
indicates a genuine scan error.

**Alternatives considered**:
- Let Ansible fail on any non-zero exit: Would cause the OpenSCAP demo to fail
  at the first scan (where non-compliance is intentional), and would prevent
  displaying scan results before failure.
- Use `ignore_errors: true`: Too broad — hides genuine errors.

**Rationale**: The `failed_when: false` + explicit rc check pattern is used by
the Ampel demo for token security reasons (`no_log: true` suppresses task
output). Applying the same pattern to the OpenSCAP demo ensures consistent error
handling across both playbooks and safely distinguishes "findings detected" from
"scan error." A separate debug task displays scan results before the failure
check runs, ensuring the user always sees the output.
