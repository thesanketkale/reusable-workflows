# Reusable Workflow: `codeql.yml`

Security static analysis workflow powered by GitHub CodeQL. Discovers security vulnerabilities, injection flaws, data exposure issues, and memory corruption patterns in C#, JavaScript/TypeScript, Python, and GitHub Actions.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/codeql.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `language` | `string` | **Yes** | N/A | Language identifier (`csharp`, `javascript-typescript`, `python`, `actions`) |
| `build-mode` | `string` | No | `'none'` | CodeQL build mode (`none`, `autobuild`, or `manual`) |

## Secrets

None.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Read source code for AST extraction |
| `security-events` | `write` | Upload SARIF results to GitHub Code Scanning dashboard |

## Outputs

None.

## Caller Example

```yaml
name: 'Security Scan'

on:
  push:
    branches: ['main']
  pull_request:
    branches: ['main']
  schedule:
    - cron: '0 6 * * 1'

permissions: {}

jobs:
  codeql:
    uses: thesanketkale/reusable-workflows/.github/workflows/codeql.yml@v1
    permissions:
      contents: read
      security-events: write
    with:
      language: 'javascript-typescript'
      build-mode: 'none'
```
