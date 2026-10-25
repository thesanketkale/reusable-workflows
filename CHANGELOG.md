# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-25

### Added
- **Application CI Pipelines:**
  - `dotnet-ci.yml`: .NET restore, build, format enforcement, test execution with cross-platform code coverage, and step summary.
  - `node-ci.yml`: Node.js frozen lockfile installation, lint, test, and build across npm, pnpm, and yarn.
  - `php-ci.yml`: Multi-version matrix for PHP 8.2, 8.3, and 8.4 with strict Composer validation, PHPStan, PHPUnit, and vulnerability audit.
- **Containers & Infrastructure:**
  - `docker-publish.yml`: Docker Buildx container publication to GHCR with multi-arch support, SBOM, and cryptographic build provenance attestations.
  - `terraform-checks.yml`: Credential-free Terraform and OpenTofu formatting, validation, TFLint, and Checkov security scanning.
  - `terraform-plan-apply.yml`: Keyless cloud plan and apply workflow with sticky PR comments and protected GitHub Environment approvals.
- **Unified Cloud Authentication:**
  - `.github/actions/cloud-login`: Composite action providing a single interface for AWS STS and Azure Entra ID OpenID Connect (OIDC) authentication.
- **Security & Release Automation:**
  - `codeql.yml`: CodeQL static analysis scanner.
  - `dependency-review.yml`: Automated pull request dependency security and license compliance evaluation.
  - `gitleaks.yml` & `.gitleaks.toml`: Complete git history secret scanning.
  - `release-please.yml` & `release.yml`: Automated semantic releases, changelog generation, and moving `v1` tag synchronization.
- **Self-Testing Harness & Fixtures:**
  - Multi-language test fixtures in `fixtures/` for .NET, Node.js, PHP, Docker, and Terraform.
  - Automated self-tests (`selftest-*.yml`) verifying all reusable workflows.
  - Negative test harness (`selftest-failure-propagation.yml`) proving that deliberate fixture failures propagate.
  - Documentation contract linter (`scripts/check-docs.sh`) verifying workflow inputs match documentation.
- **Governance & Documentation:**
  - 11-point `README.md` with complete workflow catalog and Mermaid architecture.
  - Comprehensive per-workflow reference documentation in `docs/workflows/`.
  - Security architecture and OIDC trust setup guide in `docs/security.md`.
  - Step-by-step owner-verification guide in `docs/verification-log.md`.
  - `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md`, and issue/PR templates.

## [0.1.0] - 2026-10-25

### Added
- Initial public release baseline of `reusable-workflows`.
