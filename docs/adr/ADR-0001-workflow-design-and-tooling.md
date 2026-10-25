# ADR-0001: Workflow Architecture, OIDC Security, and Tooling Baseline

- **Status:** Accepted
- **Date:** 2026-10-25
- **Author:** Sanket Kale (@thesanketkale)

## Context and Problem Statement

Downstream open-source repositories within the ecosystem (`php-api-foundation`, `electron-foundation`, `dotnet-web-foundation`, `terragrunt-baseline`, etc.) require robust, standardized CI/CD pipelines. Repetitive inline workflow configurations across multiple repositories lead to configuration drift, inconsistent security postures, outdated action versions, and maintenance overhead.

We need a centralized library of reusable workflows that:
1. Enforces least-privilege permissions and zero-trust security defaults.
2. Eliminates long-lived cloud credentials via OIDC federation.
3. Defends against supply-chain attacks through immutable action pinning.
4. Provides deterministic verification via self-tests and multi-language fixtures.
5. Keeps documentation strictly synchronized with workflow interface contracts.

## Decision Drivers

- **Security & Least Privilege:** Workflows must not inherit ambient permissions. Jobs must explicitly declare the minimal necessary OAuth scopes.
- **Supply-Chain Integrity:** Third-party GitHub Actions must not execute mutable code from tags.
- **Cloud Neutrality & Simplicity:** Common deployment primitives (AWS, Azure) must present a unified interface without proprietary lock-in.
- **Maintainability & Contract Drift:** Inputs and outputs must be strongly typed, validated, and continuously tested against documentation.

## Considered Options

1. **Option 1: Reusable Workflows (`workflow_call`)**
2. **Option 2: Composite Actions (`action.yml`) for everything**
3. **Option 3: External CLI Tool / Monorepo Task Runner (Nx, Turborepo)**

## Decision Outcome

Chosen: **Option 1 (Reusable Workflows) supplemented with focused Composite Actions**.

### 1. Architectural Division: Reusable Workflows vs. Composite Actions
- **Reusable Workflows (`workflow_call`):** Used for complete CI/CD stages (`dotnet-ci.yml`, `node-ci.yml`, `php-ci.yml`, `docker-publish.yml`, `terraform-checks.yml`, `terraform-plan-apply.yml`, etc.). Reusable workflows isolate runner environments, define granular job-level `permissions:`, support matrix configurations, and manage artifacts natively.
- **Composite Actions (`action.yml`):** Used strictly for cross-cutting step-level helpers requiring execution within the caller's runner context without launching a separate job. Specifically, `.github/actions/cloud-login` unifies AWS and Azure OIDC authentication into one step.

### 2. Action Pinning and Supply-Chain Hardening
All external third-party actions must be pinned to full 40-character commit SHAs with a human-readable trailing version comment:
```yaml
uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
```
Dependabot is configured to monitor these SHAs and submit update pull requests automatically. Mutable major tags (e.g. `@v4`) are strictly disallowed for external dependencies.

### 3. Least-Privilege Permissions Model
- Every workflow enforces minimal top-level permissions.
- Job-level permissions explicitly specify required scopes (`contents: read`, `pull-requests: write`, etc.).
- `id-token: write` is granted exclusively to jobs requiring OpenID Connect tokens (cloud authentication and cryptographic attestations).
- `pull_request_target` is completely avoided to prevent malicious fork checkouts from acquiring elevated permissions or secrets.

### 4. OIDC Federation over Static Credentials
Cloud operations authenticate solely via short-lived OpenID Connect tokens exchanged with AWS STS or Microsoft Entra ID. No long-lived `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, or Azure Client Secrets may be configured in repository secrets.

### 5. Documentation-as-Contract Verification
The script `scripts/check-docs.sh` runs as a mandatory CI gate. It parses `workflow_call.inputs` from every workflow in `.github/workflows/*.yml` and verifies that every input parameter, default value, and type is documented in `docs/workflows/<name>.md`.

## Pros and Cons of the Decision

### Positive Consequences
- Downstream repositories can invoke production-grade pipelines with one-line `uses:` declarations.
- Compromised upstream action releases cannot poison workflows without explicit Dependabot PR review.
- Cloud credentials cannot be leaked from repository secret dumps because none exist.
- Documentation never goes out of sync with actual workflow signatures.

### Negative Consequences / Trade-offs
- Calling reusable workflows introduces minor runner spin-up latency compared to pure inline composite actions.
- SHA-pinned actions require Dependabot automation to keep dependencies current.

## Alternatives Rejected

- **Using mutable action tags (`@v4`):** Rejected due to supply-chain vulnerabilities where upstream tags can be mutated or hijacked.
- **Monorepo CLI runner:** Rejected because downstream repositories are separate open-source repositories requiring standalone GitHub Actions consumption.
- **Static Cloud IAM Credentials:** Rejected due to compliance failure and severe risk of credential leakage.
