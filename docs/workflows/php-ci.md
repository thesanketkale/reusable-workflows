# Reusable Workflow: `php-ci.yml`

Continuous integration matrix pipeline for PHP 8.2, 8.3, and 8.4. Enforces strict Composer validation, dependency caching, PHPStan static analysis, PHPUnit automated test suites, and Composer vulnerability audits.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/php-ci.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `working-directory` | `string` | No | `'.'` | Path to directory containing `composer.json` |
| `extensions` | `string` | No | `'mbstring, xml, ctype, pdo, pdo_sqlite'` | Comma-separated list of PHP extensions to install |

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
name: 'PHP CI'

on:
  push:
    branches: ['main']
  pull_request:
    branches: ['main']

permissions: {}

jobs:
  api:
    uses: thesanketkale/reusable-workflows/.github/workflows/php-ci.yml@v1
    permissions:
      contents: read
    with:
      working-directory: '.'
      extensions: 'mbstring, xml, ctype, pdo, pdo_sqlite, curl'
```
