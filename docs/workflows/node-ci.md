# Reusable Workflow: `node-ci.yml`

Continuous integration pipeline for JavaScript and TypeScript projects across npm, pnpm, and yarn. Automates frozen lockfile installation, dependency caching, linting, testing, and production artifact builds.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/node-ci.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `node-version` | `string` | No | `'20.x'` | Node.js version to install (e.g. `20.x`, `22.x`) |
| `package-manager` | `string` | No | `'npm'` | Package manager to use (`npm`, `pnpm`, or `yarn`) |
| `working-directory` | `string` | No | `'.'` | Path to directory containing `package.json` |

## Secrets

None.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Clone caller repository and restore dependencies |

## Outputs

None.

## Caller Example

```yaml
name: 'Node CI'

on:
  push:
    branches: ['main']
  pull_request:
    branches: ['main']

permissions: {}

jobs:
  web-app:
    uses: thesanketkale/reusable-workflows/.github/workflows/node-ci.yml@v1
    permissions:
      contents: read
    with:
      node-version: '20.x'
      package-manager: 'pnpm'
      working-directory: './frontend'
```
