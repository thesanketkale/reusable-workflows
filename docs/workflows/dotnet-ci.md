# Reusable Workflow: `dotnet-ci.yml`

Continuous integration pipeline for .NET solutions and projects. Automates dependency restoration, compilation, code formatting enforcement, automated test execution with cross-platform code coverage collection, and test execution summaries.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/dotnet-ci.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `dotnet-version` | `string` | No | `'8.0.x'` | Target .NET SDK version (e.g. `8.0.x`, `9.0.x`) |
| `solution` | `string` | No | `'**/*.sln'` | Path or glob pattern to solution or project file |
| `configuration` | `string` | No | `'Release'` | Build configuration (`Debug` or `Release`) |
| `test-filter` | `string` | No | `''` | Optional `TestCaseFilter` expression for `dotnet test` |

## Secrets

None.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Clone caller repository and restore dependencies |

## Outputs

None. (Coverage artifacts are uploaded to workflow run storage as `dotnet-coverage-results` and rendered in `$GITHUB_STEP_SUMMARY`).

## Caller Example

```yaml
name: 'CI'

on:
  push:
    branches: ['main']
  pull_request:
    branches: ['main']

permissions: {}

jobs:
  dotnet:
    uses: thesanketkale/reusable-workflows/.github/workflows/dotnet-ci.yml@v1
    permissions:
      contents: read
    with:
      dotnet-version: '8.0.x'
      solution: 'MyProject.sln'
      configuration: 'Release'
```
