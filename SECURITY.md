# Security Policy

## Supported Versions

`reusable-workflows` provides security updates and fixes for the current moving major tag (`v1`) and the latest release tag.

| Version | Supported          |
| ------- | ------------------ |
| `v1` / `v1.x` | :white_check_mark: |
| `< v1.0` | :x:                |

## Reporting a Vulnerability

We take the security of our reusable workflows seriously. If you discover a vulnerability or potential security risk:

1. **Do not disclose the issue publicly.** Do not open public GitHub issues or discussions for potential security vulnerabilities.
2. **Submit via GitHub Private Vulnerability Reporting:**
   - Navigate to the **Security** tab of this repository.
   - Click on **Report a vulnerability** to open an encrypted advisory draft.
3. **Alternative Reporting:**
   - If GitHub Private Vulnerability Reporting is unavailable, send an email to `contact@sanketkale.com` with the subject `[SECURITY] reusable-workflows vulnerability report`.

### Information to Include
- Detailed description of the potential vulnerability or privilege escalation path.
- Affected workflow file(s) or composite action(s).
- Proof-of-concept steps or caller workflow YAML demonstrating the vulnerability.
- Any suggested remediations or mitigations.

### Response Timeline
- **Initial Acknowledgement:** Within 48 hours.
- **Triage & Status Assessment:** Within 5 business days.
- **Fix & Advisory Release:** Coordinated with reporter prior to public release.

## Security Practices in this Repository

- **Action Pinning:** All external dependencies are pinned to 40-character commit SHAs.
- **Zero Static Credentials:** Workflows use OpenID Connect (OIDC) rather than long-lived API keys.
- **Least-Privilege Scoping:** Permissions are defaulted to `{}` and explicitly defined per job.
- **Continuous Scans:** Automated CodeQL analysis, Dependabot alerts, and Gitleaks scanning run on every commit.
