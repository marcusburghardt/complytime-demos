## Why

The complytime ecosystem has undergone significant architectural changes: complyctl
was redesigned to use Gemara (replacing OSCAL), plugins were renamed to providers
and moved to a dedicated repository (complytime-providers), and a third provider
(OPA) was introduced. The complytime-demos environment has not been updated to
reflect these changes, making it unable to properly build, install, or test the
current versions of complyctl and its providers in a Fedora VM. Additionally, the
VM targets Fedora 43 while Fedora 44 is the current stable release.

## What Changes

- **Vagrantfile**: Update from Fedora 43 to Fedora 44, fix misleading comment.
- **Binary dev playbook** (`populate_complyctl_dev_binaries.yml`):
  - Build from two local repositories (complyctl + complytime-providers) instead of
    one.
  - Update provider binary source paths to come from complytime-providers repo.
  - Fix provider destination to `~/.local/share/complytime/providers/` (matching
    complyctl's XDG-based discovery).
  - Add OPA provider (third provider).
  - Remove mock-oci-registry binary copy (no longer needed).
  - Install ampel provider runtime dependencies (snappy, ampel CLI) via
    `go install`.
  - Update RPM removal task with current package names.
- **RPM dev playbook** (`populate_complyctl_dev_rpm.yml`):
  - Build RPMs from local working branches of both repositories instead of cloning
    from GitHub.
  - Derive version from latest git tag on the current branch.
  - Archive local source via `git archive`, transfer to VM, and `rpmbuild` there.
  - Build complytime-providers RPMs (openscap, ampel, opa sub-packages).
  - Ensure RPM build toolchain is installed on the VM.
  - Install ampel provider runtime dependencies (snappy, ampel CLI) via
    `go install`.
  - Remove post-install complyctl plan/generate steps (users test manually).
- **Content template** (`complytime.yaml.j2`):
  - Replace mock-oci-registry URLs with real quay.io policy URLs.
  - Scope to ampel policies only (OpenSCAP CIS policies not yet published on
    quay.io).
- **Cleanup**:
  - Remove static `files/ampel-policies/` (content now comes from `complyctl get`).
  - Update README.md for current two-repo architecture.
  - Add historical note to CONTENT_TRANSFORMATION.md.

## Capabilities

### New Capabilities

- `dev-binary-workflow`: Defines how complyctl and providers are built from local
  source and deployed as binaries to the demo VM for rapid development testing.
- `dev-rpm-workflow`: Defines how complyctl and providers are built as RPMs from
  local branches and installed on the demo VM to simulate downstream Fedora
  packaging.

### Modified Capabilities

_None (no existing specs to modify)._

## Impact

- **Files changed**: `base_vms/fedora/Vagrantfile`,
  `base_ansible_env/populate_complyctl_dev_binaries.yml`,
  `base_ansible_env/populate_complyctl_dev_rpm.yml`,
  `base_ansible_env/templates/complytime.yaml.j2`, `README.md`,
  `CONTENT_TRANSFORMATION.md`.
- **Files removed**: `base_ansible_env/files/ampel-policies/` directory (5 JSON
  files).
- **Dependencies**: Requires local clones of both `complytime/complyctl` and
  `complytime/complytime-providers` repositories.
- **Not affected**: `populate_complyctl_dev_content.yml`,
  `demo_complyctl_fedora.yml`, `run_complybeacon_fedora.yml` (deferred to
  follow-up work).
