# Reusable Workflow: `gitleaks.yml`

Hardened secret and API credential detection workflow powered by Gitleaks. Performs complete git history audits or pull request delta audits to prevent private keys, API tokens, and confidential credentials from leaking.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/gitleaks.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `config-path` | `string` | No | `'.gitleaks.toml'` | Path to custom Gitleaks configuration file |
| `fetch-depth` | `number` | No | `0` | Git history fetch depth (0 for full history scan) |

## Secrets

None.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Read git commit tree and historical commits |

## Outputs

None.

## Caller Example

```yaml
name: 'Secret Scan'

on:
  push:
    branches: ['main']
  pull_request:

permissions: {}

jobs:
  secrets:
    uses: thesanketkale/reusable-workflows/.github/workflows/gitleaks.yml@v1
    permissions:
      contents: read
    with:
      config-path: '.gitleaks.toml'
      fetch-depth: 0
```
