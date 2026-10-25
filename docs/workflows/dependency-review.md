# Reusable Workflow: `dependency-review.yml`

Supply chain defense workflow executing GitHub Dependency Review on pull requests. Detects vulnerable package additions, license compliance violations, and unexpected dependency changes before merging.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/dependency-review.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `fail-on-severity` | `string` | No | `'high'` | Severity threshold to block merge (`low`, `moderate`, `high`, `critical`) |
| `license-check` | `boolean` | No | `true` | Enforce approved license compliance check |
| `allow-licenses` | `string` | No | `'MIT, Apache-2.0, BSD-2-Clause, BSD-3-Clause, ISC, 0BSD, CC0-1.0'` | Comma-separated list of approved SPDX license identifiers |

## Secrets

None.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Read dependency lockfiles and git diffs |
| `pull-requests` | `write` | Comment review summary and block PR on policy violation |

## Outputs

None.

## Caller Example

```yaml
name: 'Dependency Review'

on:
  pull_request:

permissions: {}

jobs:
  review:
    uses: thesanketkale/reusable-workflows/.github/workflows/dependency-review.yml@v1
    permissions:
      contents: read
      pull-requests: write
    with:
      fail-on-severity: 'high'
      license-check: true
```
