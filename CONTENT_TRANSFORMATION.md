## Poetry Commands for transforming RHEL9 Profiles in CaC/content to OSCAL Content

The commands for each RHEL9 Profile transform CaC/content to an OSCAL Catalog, Profile(s), and Component Definition(s).

The commands for transforming CaC/content leverage [complyscribe](https://github.com/complytime/complyscribe) for authoring OSCAL Content.


##### Generating OSCAL Profile from RHEL9 Profile with ANSSI content

```bash
# Generating an OSCAL Catalog using the anssi cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id anssi --repo-path ~/demos/tmp-trestle-demos --oscal-catalog anssi --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the anssi OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id anssi --repo-path ~/demos/tmp-trestle-demos --oscal-catalog anssi --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for anssi_bp28_minimal using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_minimal --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-minimal --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for anssi_bp28_minimal using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_minimal --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-minimal --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for anssi_bp28_intermediary using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_intermediary --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-intermediary --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for anssi_bp28_intermediary using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_intermediary --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-intermediary --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for anssi_bp28_high using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_high --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-high --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for anssi_bp28_high using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_high --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-high --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for anssi_bp28_enhanced using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_enhanced --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-enhanced --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for anssi_bp28_enhanced using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile anssi_bp28_enhanced --repo-path ~/demos/tmp-trestle-demos --oscal-profile anssi-enhanced --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

```

##### Generating OSCAL Profile from RHEL9 Profile with CCN content

```bash

# Generating an OSCAL Catalog using the ccn_rhel9 cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id ccn_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ccn_rhel9 --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the ccn_rhel9 OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id ccn_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ccn_rhel9 --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ccn_basic using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ccn_basic --repo-path ~/demos/tmp-scribe-demos --oscal-profile ccn_rhel9-basic --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ccn_basic using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ccn_basic --repo-path ~/demos/tmp-scribe-demos --oscal-profile ccn_rhel9-basic --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ccn_intermediate using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ccn_intermediate --repo-path ~/demos/tmp-scribe-demos --oscal-profile ccn_rhel9-intermediate --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ccn_intermediate using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ccn_intermediate --repo-path ~/demos/tmp-scribe-demos --oscal-profile ccn_rhel9-intermediate --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ccn_advanced using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ccn_advanced --repo-path ~/demos/tmp-scribe-demos --oscal-profile ccn_rhel9-advanced --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ccn_advanced using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ccn_advanced --repo-path ~/demos/tmp-scribe-demos --oscal-profile ccn_rhel9-advanced --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile with CIS content

```bash

# Generating an OSCAL Catalog using the cis_rhel9 cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id cis_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog cis_rhel9 --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the cis_rhel9 OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id cis_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog cis_rhel9 --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for cis_server_l1 using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis_server_l1 --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l1_server --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for cis_server_l1 using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis_server_l1 --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l1_server --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for cis using the cis_rhel9-l2_server profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l2_server --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for cis using the cis_rhel9-l2_server profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l2_server --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for cis_workstation_l1 using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis_workstation_l1 --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l1_workstation --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for cis_workstation_l1 using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis_workstation_l1 --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l1_workstation --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for cis_workstation_l2 using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis_workstation_l2 --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l2_workstation --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for cis_workstation_l2 using the profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cis_workstation_l2 --repo-path ~/demos/tmp-scribe-demos --oscal-profile cis_rhel9-l2_workstation --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile with OSPP content

```bash

# Generating an OSCAL Catalog using the ospp cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id ospp --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ospp --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the ospp OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id ospp --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ospp --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ospp using the ospp-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ospp --repo-path ~/demos/tmp-scribe-demos --oscal-profile ospp-base --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ospp using the ospp-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ospp --repo-path ~/demos/tmp-scribe-demos --oscal-profile ospp-base --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```


##### Generating OSCAL Profile from RHEL9 Profile with OSPP and CUI content
```bash

# Generating an OSCAL Catalog using the ospp cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id ospp --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ospp --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the ospp OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id ospp --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ospp --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ospp using the ospp-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cui --repo-path ~/demos/tmp-scribe-demos --oscal-profile ospp-base --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ospp using the ospp-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile cui --repo-path ~/demos/tmp-scribe-demos --oscal-profile ospp-base --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile with E8 content

```bash

# Generating an OSCAL Catalog using the e8 cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id e8 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog e8 --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the e8 OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id e8 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog e8 --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for e8 using the e8-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile e8 --repo-path ~/demos/tmp-scribe-demos --oscal-profile e8-base --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for e8 using the e8-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile e8 --repo-path ~/demos/tmp-scribe-demos --oscal-profile e8-base --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile with HIPAA content

```bash

# Generating an OSCAL Catalog using the hipaa cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-catalog hipaa --branch main --committer-name test --committer-email test@redhat.com --dry-run  

# Generating an OSCAL Profile leveraging the hipaa OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-catalog hipaa --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for hipaa using the hipaa-addressable profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-profile hipaa-addressable --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for hipaa using the hipaa-addressable profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-profile hipaa-addressable --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for hipaa using the hipaa-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-profile hipaa-base --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for hipaa using the hipaa-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-profile hipaa-base --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for hipaa using the hipaa-required profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-profile hipaa-required --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for hipaa using the hipaa-required profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile hipaa --repo-path ~/demos/tmp-scribe-demos --oscal-profile hipaa-required --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile with ISM content

```bash
# Generating an OSCAL Catalog using the ism_o cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ism_o --branch main --committer-name test --committer-email test@redhat.com --dry-run  

# Generating an OSCAL Profile leveraging the ism_o OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-catalog ism_o --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ism_o using the ism_o-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-profile ism_o-base --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ism_o using the ism_o-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-profile ism_o-base --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ism_o using the ism_o-secret profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-profile ism_o-secret --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ism_o using the ism_o-secret profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-profile ism_o-secret --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for ism_o using the ism_o-top_secret profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-profile ism_o-top_secret --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for ism_o using the ism_o-top_secret profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile ism_o --repo-path ~/demos/tmp-scribe-demos --oscal-profile ism_o-top_secret --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```
##### Generating OSCAL Profile from RHEL9 Profile with PCI-DSS content

```bash

# Generating an OSCAL Catalog using the pcidss_4 cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id pcidss_4 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog pcidss_4 --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the pcidss_4 OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id pcidss_4 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog pcidss_4 --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for pci-dss using the pcidss_4-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile pci-dss --repo-path ~/demos/tmp-scribe-demos --oscal-profile pcidss_4-base --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for pci-dss using the pcidss_4-base profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile pci-dss --repo-path ~/demos/tmp-scribe-demos --oscal-profile pcidss_4-base --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile with STIG content

```bash

# Generating an OSCAL Catalog using the stig_rhel9 cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id stig_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog stig_rhel9 --branch main --committer-name test --committer-email test@redhat.com --dry-run 

# Generating an OSCAL Profile leveraging the stig_rhel9 OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id stig_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog stig_rhel9 --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for pci-dss using the stig_rhel9-low profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-low --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for pci-dss using the stig_rhel9-low profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-low --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for pci-dss using the stig_rhel9-medium profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-medium --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for pci-dss using the stig_rhel9-medium profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-medium --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for pci-dss using the stig_rhel9-high profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-high --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for pci-dss using the stig_rhel9-high profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-high --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

##### Generating OSCAL Profile from RHEL9 Profile for stig_gui with STIG content

```bash
# Generating an OSCAL Catalog using the stig_rhel9 cac-policy-id from CaC/content.
poetry run complyscribe sync-cac-content catalog --cac-content-root ~/CaC/forked_content/content --cac-policy-id stig_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog stig_gui --branch main --committer-name test --committer-email test@redhat.com --dry-run

# Generating an OSCAL Profile leveraging the stig_gui OSCAL Catalog and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content profile --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-policy-id stig_rhel9 --repo-path ~/demos/tmp-scribe-demos --oscal-catalog stig_gui --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for stig_gui using the stig_rhel9-low profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig_gui --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-low --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for stig_gui using the stig_rhel9-low profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig_gui --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-low --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for stig_gui using the stig_rhel9-medium profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig_gui --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-medium --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for stig_gui using the stig_rhel9-medium profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig_gui --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-medium --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Generating an OSCAL Component Definition for stig_gui using the stig_rhel9-high profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig_gui --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-high --component-definition-type software --committer-name test --committer-email test@redhat.com --branch main --dry-run

# Updating an OSCAL Component Definition to include a validation component for stig_gui using the stig_rhel9-high profile created and the RHEL9 CaC/content.
poetry run complyscribe sync-cac-content component-definition --product rhel9 --cac-content-root ~/CaC/forked_content/content --cac-profile stig_gui --repo-path ~/demos/tmp-scribe-demos --oscal-profile stig_rhel9-high --component-definition-type validation --committer-name test --committer-email test@redhat.com --branch main --dry-run
```

