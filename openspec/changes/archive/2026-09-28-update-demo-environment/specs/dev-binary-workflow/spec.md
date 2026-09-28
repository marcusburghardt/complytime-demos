## Purpose

Defines the binary development workflow for building complyctl and providers from
local source repositories and deploying them to a Fedora demo VM for rapid testing.

**Related spec**: `dev-rpm-workflow` -- the RPM-based installation workflow for the
same VM. Requirements marked *(shared)* appear in both specs and MUST use identical
values (repository paths, package names, tool versions) to avoid divergence.
Implementation SHOULD centralize shared values.

## ADDED Requirements

### Requirement: Two-repository source configuration *(shared)*

The playbook SHALL accept configurable paths for two local source repositories:
one for complyctl and one for complytime-providers. Each path MUST have a sensible
default value that developers can override without editing the playbook.

#### Scenario: Default repository paths are used

- **WHEN** the playbook is run without overriding repository path variables
- **THEN** the default paths are used to locate the complyctl and
  complytime-providers local clones

#### Scenario: Custom repository paths are provided

- **WHEN** the playbook is run with custom values for repository path variables
  (via `-e` or inventory vars)
- **THEN** the provided paths are used instead of the defaults

### Requirement: Local binary builds

The playbook SHALL build complyctl and all provider binaries from local source on
the host machine (delegate to localhost), not on the VM.

#### Scenario: complyctl binary is built locally

- **WHEN** the playbook runs the build step for complyctl
- **THEN** it executes `make build` in the complyctl repository on the host machine

#### Scenario: Provider binaries are built locally

- **WHEN** the playbook runs the build step for providers
- **THEN** it executes `make build` in the complytime-providers repository on the
  host machine, producing `complyctl-provider-openscap`,
  `complyctl-provider-ampel`, and `complyctl-provider-opa` binaries

### Requirement: Correct provider installation path

The playbook SHALL install provider binaries to the XDG-compliant user data
directory (`~/.local/share/complytime/providers/`) that complyctl's discovery
mechanism searches with highest priority.

#### Scenario: Providers are placed in XDG user data directory

- **WHEN** provider binaries are copied to the VM
- **THEN** they are placed in `~/.local/share/complytime/providers/` with
  executable permissions

#### Scenario: Provider discovery succeeds after installation

- **WHEN** complyctl runs on the VM after binary installation
- **THEN** it discovers all providers via its XDG-based discovery mechanism

### Requirement: All three providers are deployed

The playbook SHALL deploy all three provider binaries: complyctl-provider-openscap,
complyctl-provider-ampel, and complyctl-provider-opa.

#### Scenario: Three providers are copied to the VM

- **WHEN** the playbook completes the provider deployment tasks
- **THEN** the VM has `complyctl-provider-openscap`, `complyctl-provider-ampel`,
  and `complyctl-provider-opa` in the provider directory

### Requirement: Clean removal of previous installations *(shared)*

The playbook SHALL remove any previously installed RPM packages before deploying
binaries, using the current package names (complyctl, complytime-providers-openscap,
complytime-providers-ampel, complytime-providers-opa).

#### Scenario: Stale RPM packages are removed

- **WHEN** the playbook starts
- **THEN** it removes the RPM packages `complyctl`,
  `complytime-providers-openscap`, `complytime-providers-ampel`, and
  `complytime-providers-opa` if installed

### Requirement: No mock-oci-registry dependency

The playbook SHALL NOT build, copy, or reference the mock-oci-registry binary.

#### Scenario: Mock registry is absent from the workflow

- **WHEN** the playbook completes
- **THEN** no mock-oci-registry binary exists in `~/bin/` as a result of this
  playbook

### Requirement: Ampel provider runtime dependencies *(shared)*

The playbook SHALL install the snappy and ampel CLI tools required at runtime by
the ampel provider, using `go install` with pinned versions.

#### Scenario: Snappy and ampel tools are installed

- **WHEN** the playbook runs the tool installation tasks
- **THEN** snappy and ampel binaries are available in `~/go/bin/` and the PATH is
  configured to include that directory
