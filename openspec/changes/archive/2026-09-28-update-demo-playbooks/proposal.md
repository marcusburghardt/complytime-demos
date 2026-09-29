# Proposal

## Why

The `demo_complyctl_fedora.yml` playbook was written before complyctl v1.0.0 and
the complytime-policies repository. It references a non-existent `cis-fedora`
policy ID, hardcodes the binary path `~/bin/complyctl`, and assumes prior manual
setup via the `populate_*` development playbooks. Meanwhile, complyctl and all
three providers are now official Fedora packages installable via `dnf`, and CIS
Fedora L1 Server policies are published as OCI artifacts on quay.io. The playbook
cannot run as-is and does not demonstrate the real user workflow.

Additionally, there is no demo for the Ampel provider (GitHub branch-protection
scanning), which is a key use case for complyctl. A second playbook is needed to
show this workflow end-to-end.

## What Changes

- **Rewrite `demo_complyctl_fedora.yml`**: Self-contained OpenSCAP demo that
  installs packages via `dnf`, creates the workspace config inline, fetches the
  CIS Fedora L1 Server policy from quay.io, and runs the break-scan-fix-rescan
  cycle. Uses bare `complyctl` (RPM-installed), correct policy ID
  (`cis-fedora-l1-server`), and the `profile: cis_server_l1` target variable
  required by the OpenSCAP provider.
- **New `demo_complyctl_github.yml`**: Self-contained Ampel demo that installs
  packages via `dnf`, installs `snappy` and `ampel` CLI tools via `go install`
  (pinned versions with `-e` override), creates the workspace config inline,
  fetches the ampel-bp policy from quay.io, and scans the `complytime-demos`
  repository's branch protection rules. Handles `GITHUB_TOKEN` securely via
  controller-side environment variable with `no_log: true` to prevent token
  leakage in recorded sessions.
- **Update `README.md`**: Document both demo playbooks with prerequisites,
  usage, and expected output. Remove references to `populate_*` playbooks as
  prerequisites for running demos.

## Capabilities

### New Capabilities

- `demo-openscap-fedora`: Defines the self-contained OpenSCAP CIS L1 Server
  compliance demo workflow on a Fedora VM, including package installation,
  workspace setup, policy fetching, and the break-scan-fix-rescan cycle.
- `demo-ampel-github`: Defines the self-contained Ampel branch-protection
  compliance demo workflow, including package installation, tool setup, secure
  token handling, policy fetching, and GitHub repository scanning.

### Modified Capabilities

_None (no existing specs to modify)._

### Removed Capabilities

_None (no capabilities removed)._

## Impact

- **Files changed**: `base_ansible_env/demo_complyctl_fedora.yml`, `README.md`.
- **Files created**: `base_ansible_env/demo_complyctl_github.yml`.
- **Dependencies**: Fedora packages `complyctl`, `complytime-providers-openscap`,
  `complytime-providers-ampel` (from Fedora repos). Go tools `snappy` and `ampel`
  (from `github.com/carabiner-dev`, pinned versions with `-e` override). OCI
  artifacts from `quay.io/complytime/`.
- **Not affected**: `populate_complyctl_dev_binaries.yml`,
  `populate_complyctl_dev_rpm.yml`, `populate_complyctl_dev_content.yml`,
  `templates/complytime.yaml.j2`, `run_complybeacon_fedora.yml`, `Vagrantfile`.

## Constitution Alignment

### I. Single Source of Truth

Each playbook defines its own configuration values (policy IDs, OCI URLs, target
configs) because these values differ between the two demos and are specific to
each scenario. Common values (`complyctl`, `complytime.yaml` filename) are
dictated by external tool conventions, not project constants. Go tool versions are
defined as playbook variables (single source) rather than hardcoded inline. No
violation -- design decision D1 documents the rationale for per-playbook inline
config over shared templates.

### II. Simplicity & Isolation

Each playbook is self-contained and single-purpose. No shared state or coupling
between the two demos. Dependencies are installed within each playbook, following
the real user workflow.

### III. Incremental Improvement

This change is focused on a single concern: demo playbooks. No unrelated changes
to development playbooks, templates, or infrastructure.

### IV. Readability First

Inline configuration (design decision D1) prioritizes readability over DRY
abstraction. Each playbook can be understood without jumping to template files.
Explicit variable names and task descriptions follow Ansible best practices.

### V. Do Not Reinvent the Wheel

Uses Ansible built-in modules (`dnf`, `lineinfile`, `replace`, `copy`, `fetch`),
standard package managers (`dnf`, `go install`), and existing `complyctl` CLI
commands. No custom tooling introduced.

### VI. Composability

Each playbook does one thing well: demonstrate a single complyctl provider
workflow. Output artifacts (evaluation logs, reports) use standard formats
consumable by other tools.

### VII. Convention Over Configuration

Playbooks install their own dependencies (design decision D5), requiring minimal
user configuration. The only prerequisite is `vagrant up` (and `GITHUB_TOKEN` for
Ampel). Sensible defaults for versions, paths, and policy IDs.
