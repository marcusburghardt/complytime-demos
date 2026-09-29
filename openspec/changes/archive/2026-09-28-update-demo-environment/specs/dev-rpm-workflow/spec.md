## Purpose

Defines the RPM development workflow for building complyctl and complytime-providers
RPMs from local working branches and installing them on a Fedora demo VM to simulate
downstream Fedora packaging behavior.

**Related spec**: `dev-binary-workflow` -- the binary-based installation workflow for
the same VM. Requirements marked *(shared)* appear in both specs and MUST use
identical values (repository paths, package names, tool versions) to avoid
divergence. Implementation SHOULD centralize shared values.

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

### Requirement: Version derived from local git tags

The playbook SHALL derive the RPM version from the latest git tag reachable from
HEAD in each local repository, stripping the leading `v` prefix. If no tag is
reachable from HEAD, the playbook SHALL fail with a clear error message instructing
the developer to create a version tag.

#### Scenario: Version is extracted from complyctl repo

- **WHEN** the playbook prepares the complyctl RPM build
- **THEN** it reads the latest git tag from the current branch (e.g., `v0.0.8`
  becomes `0.0.8`) and uses it as the RPM Version

#### Scenario: Version is extracted from providers repo

- **WHEN** the playbook prepares the complytime-providers RPM build
- **THEN** it reads the latest git tag from the current branch (e.g., `v0.1.0`
  becomes `0.1.0`) and uses it as the RPM Version

### Requirement: Source archived from local working branch

The playbook SHALL create source tarballs from the local repositories using
`git archive` on the current branch HEAD, performed on the host machine
(delegate to localhost). These tarballs SHALL be transferred to the VM for
rpmbuild.

#### Scenario: Tarball is created from local complyctl branch

- **WHEN** the playbook prepares the complyctl source
- **THEN** it runs `git archive HEAD` in the local complyctl repo and copies the
  resulting tarball to the VM's `rpmbuild/SOURCES/` directory

#### Scenario: Tarball is created from local providers branch

- **WHEN** the playbook prepares the complytime-providers source
- **THEN** it runs `git archive HEAD` in the local complytime-providers repo and
  copies the resulting tarball to the VM's `rpmbuild/SOURCES/` directory

### Requirement: RPMs built on the VM

All RPM builds SHALL execute on the Fedora VM (not on the host), ensuring the
build environment matches the target Fedora release.

#### Scenario: complyctl RPM is built on the VM

- **WHEN** the complyctl tarball and spec file are on the VM
- **THEN** `rpmbuild -bb` runs on the VM to produce the complyctl RPM package

#### Scenario: complytime-providers RPMs are built on the VM

- **WHEN** the complytime-providers tarball and spec file are on the VM
- **THEN** `rpmbuild -bb` runs on the VM to produce the complytime-providers-openscap,
  complytime-providers-ampel, and complytime-providers-opa RPM sub-packages

### Requirement: All RPMs installed via dnf

The playbook SHALL install all locally built RPMs using `dnf` with GPG check
disabled (locally built packages are unsigned).

#### Scenario: Built RPMs are installed

- **WHEN** all RPM builds complete successfully
- **THEN** all resulting RPM files are installed via `dnf` on the VM

### Requirement: Clean removal of previous installations *(shared)*

The playbook SHALL remove any previously installed complyctl and provider RPM
packages before building and installing new ones, using the current package names.

#### Scenario: Previous RPMs are removed before rebuild

- **WHEN** the playbook starts
- **THEN** it removes the RPM packages `complyctl`,
  `complytime-providers-openscap`, `complytime-providers-ampel`, and
  `complytime-providers-opa` if installed

### Requirement: Build dependencies installed on VM

The playbook SHALL ensure the RPM build toolchain (rpmdevtools, rpmlint, golang,
go-rpm-macros) is installed on the VM before attempting any builds.

#### Scenario: RPM build tools are available

- **WHEN** the playbook prepares the VM for RPM builds
- **THEN** rpmdevtools, rpmlint, golang, and go-rpm-macros are installed

### Requirement: No post-install automation

The playbook SHALL NOT run complyctl commands (plan, generate, scan) after
installation. Users will test manually.

#### Scenario: Playbook ends after RPM installation

- **WHEN** all RPMs are installed
- **THEN** the playbook completes without executing any complyctl subcommands

### Requirement: Ampel provider runtime dependencies *(shared)*

The playbook SHALL install the snappy and ampel CLI tools required at runtime by
the ampel provider, using `go install` with pinned versions.

#### Scenario: Snappy and ampel tools are installed

- **WHEN** the playbook runs the tool installation tasks
- **THEN** snappy and ampel binaries are available in `~/go/bin/` and the PATH is
  configured to include that directory
