# AGENTS.md: reusable-workflows

Shared rules for every AI agent on this repo, in Claude Code (through CLAUDE.md) and Google Antigravity (which reads this file directly).

## Project
- What it is: Versioned, least-privilege reusable GitHub Actions workflows for .NET, Node, PHP, Docker, Terraform and release automation.
- Users: Engineering teams configuring CI/CD pipelines across the repository suite and external open-source consumers.
- Related repos and contracts: Works as an upstream workflow provider for `php-api-foundation`, `electron-foundation`, `dotnet-web-foundation`, and `terragrunt-baseline`.

## Stack packs
- github-actions

## Commands
- Install: None (pure GitHub Actions & Shell tooling)
- Run locally: none (workflow library)
- Verify fast: `pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1 fast` (or `bash scripts/verify.sh fast`)
- Verify full: `pwsh -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1 full` (or `bash scripts/verify.sh full`)
- Disposable database: none

## Git
- Base branch: main
- Branches: `main`, `feat/<slug>`, `fix/<slug>`, `chore/<slug>`
- PR: manual

## Conventions
- This is a public MIT repository written clean-room: no code, assets, names or data from client or employer projects. Sample data is synthetic.
- The standards and this repository's requirements are in `.pipeline/SPEC.md` (local, never committed). Requirement IDs appear in AC lines as `AC-n [ID]` and in test names.
- Docs describe only what exists and was run. What an agent cannot run (push, live cloud, signing, a Unity Editor, GitHub settings) is a `[USER]` item in `docs/release-checklist.md` and is never described as tested.
- Every reusable workflow must use `on.workflow_call` with typed inputs, explicit descriptions, sensible defaults, and documented outputs.
- Workflows live in `.github/workflows/`. Reusable ones are named after what they do (`dotnet-ci.yml`). Self-tests are integrated into `ci.yml`. A workflow is never changed without updating `docs/workflows/<name>.md` in the same commit (`scripts/check-docs.sh` enforces it).
- GitHub Actions: top-level `permissions: {}` plus minimal per-job permissions (`contents: read`, `id-token: write` only for OIDC/attestation); `timeout-minutes` and `concurrency` on every workflow; actions pinned to a full SHA with the version in a comment; explicit `shell:`; LF line endings; no `${{ github.event.* }}` inside `run:` (use `env:`); OIDC for cloud login. Check with `actionlint`.
- `id-token: write` appears only in `terraform-plan-apply.yml` and `.github/actions/cloud-login`.
- Fixtures under `fixtures/` are tiny and synthetic. One variant per language fails on purpose, and tests assert that the failure propagates.
- Terraform in fixtures: `fmt`, `validate` and `plan` against nothing. No `apply`, no state commands, no credentials.
- Cross-platform scripts and composite actions must specify `shell: bash` or `shell: pwsh`.
- Commits are small and follow `<type>(<scope>): <goal> [step N]`. Dates are real and history is never rewritten.
- Dependencies need MIT-compatible licences. Record stack choices and open-decision outcomes in `docs/adr/`.

## Design
- None (workflow library, `--no-design`).

## Safety: agents never do these. They prepare the command and hand it over.
- Deploy, publish, release, upload, sign or notarize builds
- `terraform` / `terragrunt` apply, destroy, import or any state command
- Push to remote `main`, force-push, rewrite published history
- Never push, tag, create releases, change GitHub settings or run `git filter-repo`; write the command into `docs/release-checklist.md` instead.
- Store or print real secrets in logs or fixtures. Never print secret values: show only file, line, rule and the last four characters.
