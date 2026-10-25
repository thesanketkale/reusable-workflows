# Contributing to reusable-workflows

Thank you for your interest in contributing to `reusable-workflows`! This repository provides hardened, least-privilege GitHub Actions workflows used across the `@thesanketkale` ecosystem.

---

## 1. Clean-Room Rule & Code of Conduct

- **Clean-room standards:** All code, examples, documentation, and test fixtures must be authored from scratch. Never include code, assets, private names, internal domains, or proprietary configurations from client projects.
- **Sample data:** All identifiers, domains, account numbers, and tokens in examples and fixtures must be synthetic (e.g. `111111111111`, `example.com`).
- **Code of conduct:** All participants must abide by the [Code of Conduct](CODE_OF_CONDUCT.md) (Contributor Covenant 2.1).

---

## 2. Conventional Commits

We enforce the [Conventional Commits](https://www.conventionalcommits.org/) specification (`feat:`, `fix:`, `docs:`, `ci:`, `test:`, `chore:`).
Commit messages drive automated changelogs and semantic versioning via `release-please`.

Examples:
- `feat(node): add bun runtime option to node-ci`
- `fix(terraform): quote directory path in tflint execution`
- `docs(workflows): add example for docker-publish multi-arch`

---

## 3. Workflow Authoring Standards

When adding or modifying a reusable workflow:
1. **Trigger:** Use `on.workflow_call` exclusively for reusable workflows.
2. **Permissions:** Top-level permissions must be minimal (`permissions: {}`). Explicitly grant minimum required permissions per job (e.g. `contents: read`).
3. **Action Pinning:** Every third-party action must be pinned to an immutable 40-character commit SHA with a trailing version comment:
   ```yaml
   uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2
   ```
4. **Documentation Contract:** Any new or modified input in a workflow must be documented in `docs/workflows/<name>.md`. Run `bash scripts/check-docs.sh` to verify.
5. **Fixtures & Self-Tests:** Provide a synthetic fixture in `fixtures/` and a corresponding self-test workflow in `.github/workflows/selftest-<name>.yml`.

---

## 4. Local Verification

Before submitting a pull request, run the local verification suite:

```bash
# Windows PowerShell:
pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1 full

# Linux / macOS:
bash scripts/verify.sh full
```

The verification suite runs:
- `actionlint` across all workflows and actions.
- `yamllint` with strict schema and line-length rules.
- `shellcheck` across all shell scripts and inline bash blocks.
- `scripts/check-docs.sh` to verify that workflow inputs match documentation.
