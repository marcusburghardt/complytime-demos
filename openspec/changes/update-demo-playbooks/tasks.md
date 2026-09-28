# Tasks

## 1. OpenSCAP Demo Playbook (demo_complyctl_fedora.yml)

- [x] 1.1 Rewrite `base_ansible_env/demo_complyctl_fedora.yml` with the setup phase: dnf install of `complyctl` and `complytime-providers-openscap` (state: latest, become: true), workspace directory creation, inline `complytime.yaml` with CIS Fedora L1 Server policy (`quay.io/complytime/policies-cis-fedora-l1-server:latest`, id: `cis-fedora-l1-server`, target `fedora-vm` with `profile: cis_server_l1`), `complyctl get`, `complyctl generate --policy-id cis-fedora-l1-server`, and `complyctl doctor`. Verify: `ansible-lint` passes on the playbook.
- [x] 1.2 Implement the prep phase: remove `firewalld`, remove `Defaults logfile=` from `/etc/sudoers`, set `UMASK 022` in `/etc/login.defs`. All `/etc/sudoers` modifications SHALL use `validate: /usr/sbin/visudo -cf %s`. Preserve the existing task logic from the old playbook. Verify: playbook contains three prep tasks: (a) `dnf` remove `firewalld` with `state: absent` and `become: true`, (b) `lineinfile` remove `Defaults logfile` from `/etc/sudoers` with `validate: /usr/sbin/visudo -cf %s` and `become: true`, (c) `replace` set `UMASK 022` in `/etc/login.defs` with `become: true`.
- [x] 1.3 Implement Phase 1 (scan with failures): run `complyctl scan fedora-vm --format pretty` with `become: true`, using `register` and `failed_when: false` to capture exit code. Add a separate task to fail if `scan_result.rc > 1` (exit code 1 indicates non-compliant findings, >1 indicates an error). Create local `./downloads_complyctl_fedora_scan1/` directory, fetch evaluation logs and reports. Verify: the fetch pattern matches `complyctl scan` output file naming (`evaluation-log-*.yaml`, `report-*.md`), and the scan task uses `register` + `failed_when: false` with a separate rc check.
- [x] 1.4 Implement Phase 2 (fix and re-scan): install `firewalld`, add `Defaults logfile=/var/log/sudo.log` to `/etc/sudoers` with `validate: /usr/sbin/visudo -cf %s`, set `UMASK 027` in `/etc/login.defs`, re-run `complyctl scan fedora-vm --format pretty` with `become: true` (same `register` + `failed_when: false` + rc check pattern), fetch results to `./downloads_complyctl_fedora_scan2/`. Verify: playbook installs `firewalld` (`state: present`, `become: true`), adds `Defaults logfile=/var/log/sudo.log` to `/etc/sudoers` with `validate: /usr/sbin/visudo -cf %s` and `become: true`, sets `UMASK 027` in `/etc/login.defs` with `become: true`, and uses the same scan error handling pattern as Phase 1.
- [x] 1.5 Implement the comparison output: display tree output from both scans, list local download directories. Verify: the playbook uses `ansible.builtin.debug` to show both tree outputs (`result_tree_scan1.stdout_lines`, `result_tree_scan2.stdout_lines`) and the paths `./downloads_complyctl_fedora_scan1/` and `./downloads_complyctl_fedora_scan2/`.

## 2. Ampel Demo Playbook (demo_complyctl_github.yml)

- [x] 2.1 Create `base_ansible_env/demo_complyctl_github.yml` with token validation: read `GITHUB_TOKEN` via `lookup('env', 'GITHUB_TOKEN')`, fail with instructional message if empty (delegate_to: localhost). Verify: running the playbook without `GITHUB_TOKEN` set produces a clear failure message including `export GITHUB_TOKEN=$(gh auth token)`.
- [x] 2.2 Implement the setup phase: dnf install of `complyctl` and `complytime-providers-ampel` (state: latest, become: true), `go install` of snappy (`@v0.2.6`) and ampel CLI (`@v1.3.6`) with version variables defined in `vars:` for easy override via `-e`, ensure `~/go/bin` is in PATH for subsequent tasks using `environment: { PATH: "{{ ansible_env.HOME }}/go/bin:{{ ansible_env.PATH }}" }` on tasks that need Go-installed tools. Verify: `ansible-lint` passes on the playbook, Go tool versions are defined as variables, and the `environment` directive is used (not `.bashrc` modification) for PATH handling.
- [x] 2.3 Implement workspace configuration: create workspace directory (`~/complyctl-demo-ampel`), inline `complytime.yaml` with ampel-bp policy (`quay.io/complytime/policies-ampel-branch-protection:latest`, id: `ampel-bp`, target `complytime-demos` with `url: https://github.com/complytime/complytime-demos` and `specs: builtin:github/branch-rules.yaml`), run `complyctl get`, `complyctl generate --policy-id ampel-bp`, and `complyctl doctor`. Verify: inline YAML contains `policy_id: ampel-bp`, OCI reference `quay.io/complytime/policies-ampel-branch-protection:latest`, target `complytime-demos` with `url` and `specs` variables, workspace path is `~/complyctl-demo-ampel`, and `complyctl doctor` is invoked after generate.
- [x] 2.4 Implement the scan phase: run `complyctl scan complytime-demos --format pretty` with `environment: { GITHUB_TOKEN: ... , PATH: ... }` and `no_log: true`, `register: scan_result`, `failed_when: false`. Add separate `debug` task to display `scan_result.stdout_lines`. Add failure check: fail if `scan_result.rc > 1` (exit code 1 indicates non-compliant findings, >1 indicates an error). Verify: the token variable does not appear in any task definition outside the `environment` directive, `no_log: true` is set on the scan task, and the rc check distinguishes findings (rc=1) from errors (rc>1).
- [x] 2.5 Implement the fetch phase: create local `./downloads_complyctl_github/` directory, fetch evaluation logs and reports, display download directory path. Verify: fetch patterns match `complyctl scan` output file naming, and the download path is displayed via `ansible.builtin.debug`.

## 3. README Update

- [x] 3.1 Update the `README.md` demo playbooks section: replace the "Note: This playbook is being updated" placeholder with full documentation for `demo_complyctl_fedora.yml` (prerequisites: `vagrant up` only, usage, what it does). Add a new section for `demo_complyctl_github.yml` (prerequisites: `vagrant up` + `GITHUB_TOKEN`, usage, what it does, token setup instructions including required scopes). Update the Playbook Variables Reference section if applicable. Verify: the README accurately describes both playbooks, does not reference `populate_*` playbooks as prerequisites for demos, and includes token scope guidance for the Ampel demo.

## 4. Validation

- [x] 4.1 Run `ansible-lint` on both playbooks and fix any issues. Verify: zero lint errors for `demo_complyctl_fedora.yml` and `demo_complyctl_github.yml`.
- [x] 4.2 Run `yamllint` on both playbooks using the repository's `.yamllint.yml` configuration. Verify: zero lint errors.
- [x] 4.3 Run `ansible-playbook --syntax-check` on both playbooks. Verify: both playbooks pass syntax validation (catches Jinja2 errors, undefined variables, and YAML parse issues that `yamllint` alone does not detect).

<!--
Verification Strategy:
- Automated (CI-feasible): ansible-lint (4.1), yamllint (4.2), syntax-check (4.3)
- Manual (requires Vagrant VM + network): All functional scenarios in specs
  (package installation, scan cycles, token handling, policy fetching)
- The functional scenarios are validated by running the playbooks against a
  provisioned Vagrant VM. These cannot be automated without the VM environment
  and network access to quay.io and github.com.
-->
<!-- spec-review: passed -->
<!-- code-review: passed -->
