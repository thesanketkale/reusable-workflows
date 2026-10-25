# Reusable Workflow: `release-please.yml`

Automated release workflow powered by Google's `release-please`. Parses Conventional Commits to generate release pull requests, update `CHANGELOG.md`, increment semantic versions, and publish tagged GitHub Releases.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/release-please.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `release-type` | `string` | No | `'simple'` | Release strategy (e.g. `simple`, `node`, `dotnet`, `terraform`) |
| `package-name` | `string` | No | `''` | Name of package being released |
| `config-file` | `string` | No | `''` | Path to custom `release-please-config.json` |
| `manifest-file` | `string` | No | `''` | Path to custom `.release-please-manifest.json` |

## Secrets

| Name | Required | Description |
|---|---|---|
| `token` | No | Optional GitHub Personal Access Token if triggering downstream workflows |

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `write` | Create release tags, push release commits, update releases |
| `pull-requests` | `write` | Create and update release pull requests |

## Outputs

| Name | Description |
|---|---|
| `releases-created` | Boolean indicating whether a release was cut |
| `tag-name` | String name of the published git tag |

## Caller Example

```yaml
name: 'Release'

on:
  push:
    branches: ['main']

permissions: {}

jobs:
  release:
    uses: thesanketkale/reusable-workflows/.github/workflows/release-please.yml@v1
    permissions:
      contents: write
      pull-requests: write
    with:
      release-type: 'simple'
```
