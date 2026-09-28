## Context

See proposal.md for motivation. The key constraints shaping this design:

- complyctl's provider discovery searches two paths in order:
  1. User dir (highest priority): `~/.local/share/complytime/providers/`
  2. System dir (fallback): `/usr/libexec/complytime/providers/`
- Providers are now in a separate repository (complytime-providers) with its own
  Makefile and RPM spec file.
- The complytime-providers RPM spec produces three sub-packages:
  `complytime-providers-openscap`, `complytime-providers-ampel`,
  `complytime-providers-opa`.
- The complyctl RPM spec no longer builds providers or the mock-oci-registry.
- OpenSCAP CIS policies are not yet published on quay.io; only ampel
  branch-protection policies are available.
- Both repos use vendored dependencies (`vendor/` committed), so no network
  dependency resolution is needed during builds.
- The VM is expected to have internet access for `complyctl get` to pull policies
  from quay.io.

## Goals / Non-Goals

**Goals:**

- Binary playbook builds and installs complyctl + 3 providers from two local repos.
- RPM playbook builds RPMs from local working branches and installs them on the VM,
  simulating downstream Fedora packaging.
- Both playbooks accept configurable local repository paths.
- Content template uses real quay.io policy URLs (ampel only).
- VM targets Fedora 44.

**Non-Goals:**

- DNF installation from Fedora repos (packages not yet available for providers).
- Complypack usage (content consumed directly via `complyctl get`).
- OpenSCAP CIS policy integration (not yet on quay.io).
- Updates to `demo_complyctl_fedora.yml`, `populate_complyctl_dev_content.yml`, or
  `run_complybeacon_fedora.yml`.
- Workspace-local provider discovery in complyctl (existing two-tier is sufficient).

## Decisions

### D1: Binary playbook installs to XDG user data directory

**Choice**: Providers go to `~/.local/share/complytime/providers/`.

**Alternatives considered**:
- `~/.complytime/providers/` (current playbook path): Not searched by complyctl.
  This was the old path and providers installed there are never discovered.
- `/usr/libexec/complytime/providers/` (system path): Would require `sudo` and
  conflicts with RPM-managed files. The user directory is the correct location for
  non-package-managed binaries.

**Rationale**: This is the path complyctl's XDG-based discovery checks first.
Placing providers here also means they override any RPM-installed providers with
the same evaluator ID, which is the desired behavior for development testing.

### D2: RPM playbook archives local source with `git archive`

**Choice**: Use `git archive HEAD` on the host to create tarballs, then transfer
them to the VM for `rpmbuild`.

**Alternatives considered**:
- Clone from GitHub on the VM (current approach): Does not support testing local
  branches. Requires the developer to push changes upstream before testing.
- rsync the full source tree to the VM: Sends `.git/` metadata and untracked
  files. Larger transfer, less clean.
- Build RPMs on the host: Requires RPM toolchain on the developer's machine,
  which may not be Fedora. Building on the VM ensures the Fedora build environment
  matches downstream.

**Rationale**: `git archive` produces a clean tarball of the committed tree on the
current branch, matching exactly what `rpmbuild` expects in `SOURCES/`. The
developer can test any local branch by checking it out before running the playbook.
The vendor directory is committed, so the tarball is self-contained.

### D3: Version derived from latest git tag reachable from HEAD

**Choice**: Run `git tag --merged HEAD --sort=-v:refname | head -1` locally and
strip the `v` prefix to get the RPM Version. If no tag is reachable from HEAD,
the playbook fails with a clear error message.

**Alternatives considered**:
- `git tag --sort=-v:refname | head -1` (all tags, regardless of branch ancestry):
  Could return a tag from a different branch whose content differs from the
  `git archive HEAD` tarball, causing a version-content mismatch.
- Parse Version from the spec file: The spec file may not always match the actual
  source version being built.
- Use `git describe`: Produces versions like `v0.0.8-3-gabcdef` which are not
  valid RPM versions without further transformation.
- Manual variable: Requires the developer to remember to set it each time.

**Rationale**: Using `--merged HEAD` ensures the tag is an ancestor of the current
HEAD, preventing version-content mismatch when building from feature branches.
This is the least manual approach and stays in sync with the source being built.

### D4: Content scoped to ampel policies only

**Choice**: The `complytime.yaml.j2` template references only
`quay.io/complytime/policies-ampel-branch-protection:latest`.

**Alternatives considered**:
- Keep the OpenSCAP CIS policy reference with a mock or placeholder URL:
  Would produce errors at `complyctl get` time since the URL does not resolve.
- Include both ampel and a hypothetical OpenSCAP URL: Risk of breakage when
  URLs change or don't exist yet.

**Rationale**: Only include policies that are actually published and available.
OpenSCAP CIS policies can be added once published on quay.io.

### D5: Fedora 44 as VM target

**Choice**: Update the Vagrantfile to use the Fedora 44 Cloud Base image.

**Rationale**: Fedora 44 is the current stable release. The RPM specs in both
complyctl and complytime-providers are being prepared for Fedora, so testing
should target the current release.

### D6: Shared variables across playbooks

**Choice**: Both playbooks define shared values (repository paths, package names,
snappy/ampel versions) in their own `vars` sections with identical defaults. A
comment in each playbook cross-references the other to signal that changes must be
applied to both.

**Alternatives considered**:
- Shared vars file via `include_vars`: Adds a file dependency and indirection for
  a relatively small set of values. Over-engineering for this stage.
- Ansible role: The playbooks are flat task lists by design. Introducing a role
  would change the repo's architecture beyond the scope of this change.
- `group_vars/demo_vm.yml`: Would require restructuring the inventory and is more
  complexity than warranted for 4-6 shared values.

**Rationale**: At this stage, both playbooks share only a handful of values
(2 repo paths, 4 package names, 2 tool versions). Cross-referencing comments are
sufficient to maintain consistency. If the shared surface grows, a `group_vars`
file or shared vars file should be introduced as a follow-up.

## Risks / Trade-offs

- **[Risk] `git archive` only captures committed content**: If a developer has
  uncommitted changes, they won't be included in the RPM build. This is intentional
  (RPMs should be built from committed state), but developers must be aware.
  Mitigation: Document this behavior in the playbook comments and README.

- **[Risk] Git tag may not exist on a new branch**: If working on a branch with no
  tags, the version derivation will fail or produce an unexpected result.
  Mitigation: The playbook should handle this gracefully with a clear error message
  or a fallback default version.

- **[Risk] Ampel-only content limits testing scope**: Without OpenSCAP CIS policies,
  the OpenSCAP provider cannot be tested end-to-end via the content workflow.
  Mitigation: This is accepted as a known limitation; OpenSCAP policies will be
  added once published. The provider binary itself is still installed and
  discoverable.

- **[Risk] Snappy and ampel tools installed via `go install`**: These are not
  packaged in Fedora and require the Go toolchain on the VM. If upstream versions
  break compatibility, pinned versions may need updating. Additionally, `go install`
  requires network access to the Go module proxy (`proxy.golang.org`), which may
  fail in environments with restricted internet or corporate proxies.
  Mitigation: Pin specific versions in playbook variables for reproducibility.
  The VM provisioning already requires internet for `dnf`, so connectivity is
  assumed.

- **[Trade-off] RPM build on VM is slower than local binary copy**: The RPM
  playbook involves source transfer, rpmbuild, and dnf install, making it
  significantly slower than the binary playbook. This is acceptable because the
  RPM path is meant for validation, not rapid iteration.
