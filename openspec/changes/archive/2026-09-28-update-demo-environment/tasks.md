## 1. VM Foundation

- [x] 1.1 Update `base_vms/fedora/Vagrantfile`: fix comment from "RHEL 9" to
  "Fedora", update `box_url` to Fedora 44 Cloud Base image, set box name to
  `f44-cloud-base`, update hostname to `fedora44`. Verify by inspecting the
  Vagrantfile for correct Fedora 44 URLs and metadata.

## 2. Binary Dev Playbook

- [x] 2.1 Update vars in `base_ansible_env/populate_complyctl_dev_binaries.yml`:
  add `providers_repo_dest` variable with a sensible default path alongside the
  existing `complyctl_repo_dest`, and update `provider_dir` from
  `~/.complytime/providers` to `~/.local/share/complytime/providers`. Verify
  both variables appear in the `vars` section with comments explaining usage.

- [x] 2.2 Add a build step for complytime-providers: insert a task that runs
  `make build` in the `providers_repo_dest` directory, delegated to localhost
  (same pattern as the existing complyctl build task). Verify the task uses
  `delegate_to: localhost` and references `providers_repo_dest`.

- [x] 2.3 Update provider binary source paths to come from the providers repo:
  change the three provider copy tasks to source from
  `{{ providers_repo_dest }}/bin/complyctl-provider-openscap`,
  `{{ providers_repo_dest }}/bin/complyctl-provider-ampel`, and
  `{{ providers_repo_dest }}/bin/complyctl-provider-opa` (new). Remove the
  old `openscap-plugin` and `ampel-plugin` source references. Verify three
  copy tasks exist with the correct source paths and all target the updated
  `provider_dir`.

- [x] 2.4 Remove the mock-oci-registry binary copy task entirely. Verify no
  task references `mock-oci-registry` in the playbook.

- [x] 2.5 Update the RPM removal task: replace `complyctl-openscap-plugin` with
  `complytime-providers-openscap`, `complytime-providers-ampel`, and
  `complytime-providers-opa`. Keep `complyctl` in the list. Verify the dnf
  removal task lists all four current package names.

- [x] 2.6 Keep the snappy and ampel `go install` tasks with pinned versions
  (snappy `v0.1.4`, ampel `v1.0.0`). Keep the `~/go/bin` PATH configuration.
  Add a comment cross-referencing the RPM playbook for shared version values.
  Verify the tasks remain in the playbook with correct pinned versions.

## 3. RPM Dev Playbook

> **Note**: Phases 1-4 can be implemented in parallel (they modify different
> files). Phase 5.2 (README) depends on all other phases being finalized.

- [x] 3.1 Rewrite vars in `base_ansible_env/populate_complyctl_dev_rpm.yml`:
  add `complyctl_repo_dest` and `providers_repo_dest` variables with sensible
  default paths and comments. Remove `repo_org`, `repo_name`, and `spec_file`
  vars (these were for the GitHub clone approach). Verify the vars section has
  configurable paths for both repos.

- [x] 3.2 Update the RPM removal task with current package names: `complyctl`,
  `complytime-providers-openscap`, `complytime-providers-ampel`,
  `complytime-providers-opa`. Verify the dnf removal task lists all four.

- [x] 3.3 Ensure RPM build dependencies are installed on the VM: add a task to
  install `rpmdevtools`, `rpmlint`, `golang`, and `go-rpm-macros` via dnf,
  and run `rpmdev-setuptree`. Verify the task runs before any rpmbuild steps.

- [x] 3.4 Add local version derivation for complyctl: insert a task (delegated
  to localhost) that runs `git tag --merged HEAD --sort=-v:refname` in the
  complyctl repo to get the latest tag reachable from HEAD, then strips the
  `v` prefix to produce the version. Register the result as a fact. Include
  error handling: if no tags are reachable from HEAD, fail with a clear
  message instructing the developer to create a version tag. Verify the task
  uses `delegate_to: localhost` and `chdir` to the complyctl repo path.

- [x] 3.5 Add local version derivation for complytime-providers: same approach
  as 3.4 but for the providers repo. Verify the task produces a separate
  version fact with the same error handling.

- [x] 3.6 Replace the GitHub clone tasks with local source archiving for
  complyctl: insert tasks (delegated to localhost) that run
  `git archive --format=tar --prefix=complyctl-<version>/ HEAD | gzip` in the
  local complyctl repo, then copy the tarball and spec file to the VM. Verify
  the tasks use `delegate_to: localhost` for archive creation and target the
  VM's `rpmbuild/SOURCES/` directory for the tarball.

- [x] 3.7 Add local source archiving for complytime-providers: same approach as
  3.6 but for the providers repo, using its own spec file
  (`complytime-providers.spec`) and version. Verify tarball and spec file
  transfer tasks exist.

- [x] 3.8 Add the rpmbuild step for complytime-providers: insert a task that
  runs `rpmbuild -bb --nodebuginfo` on the VM using the providers spec file.
  Register the output for RPM path extraction. Verify the task follows the
  same pattern as the existing complyctl rpmbuild task.

- [x] 3.9 Update RPM installation to include all built RPMs from both repos.
  Verify the dnf install task collects RPM paths from both the complyctl
  and providers build outputs.

- [x] 3.10 Remove the post-install `complyctl plan` and `complyctl generate`
  tasks. Verify the playbook ends after RPM installation with no complyctl
  subcommand execution.

- [x] 3.11 Install snappy and ampel tools via `go install` with pinned versions
  (snappy `v0.1.4`, ampel `v1.0.0`), and ensure `~/go/bin` is in PATH. Add a
  comment cross-referencing the binary playbook for shared version values.
  Verify the tasks mirror the pattern from the binary playbook.

## 4. Content Template

- [x] 4.1 Update `base_ansible_env/templates/complytime.yaml.j2`: replace
  mock-oci-registry URLs with
  `quay.io/complytime/policies-ampel-branch-protection:latest`, remove the
  OpenSCAP CIS policy entry, and update the targets section to match the
  reference `complytime.yaml` structure. Verify the template contains only
  ampel policy references and no `registry_url` or `openscap` references.

## 5. Cleanup

- [x] 5.1 Remove the `base_ansible_env/files/ampel-policies/` directory and
  all its JSON files. Verify the directory no longer exists.

- [x] 5.2 Update `README.md`: document the current two-repo architecture,
  update workflow steps for both binary and RPM paths, remove OSCAL-specific
  content sections and mock-oci-registry references. Verify the README
  accurately describes the updated playbooks and their variables.

- [x] 5.3 Add a historical note at the top of `CONTENT_TRANSFORMATION.md`
  indicating it references the previous OSCAL-based workflow and is retained
  for reference. Verify the note is present.

<!-- spec-review: passed -->
<!-- code-review: passed -->
