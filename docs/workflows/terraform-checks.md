# Reusable Workflow: `terraform-checks.yml`

Credential-free static code analysis pipeline for Terraform and OpenTofu modules. Enforces formatting rules, syntax validation, module dependency validation, TFLint linting, and Checkov DevSecOps security scanning without requiring cloud credentials.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/terraform-checks.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `working-directory` | `string` | No | `'.'` | Directory containing `.tf` files |
| `terraform-version` | `string` | No | `'1.9.0'` | CLI engine version to install |
| `use-opentofu` | `boolean` | No | `false` | When true, installs and runs OpenTofu instead of Terraform |
| `tflint-version` | `string` | No | `'v0.53.0'` | Release version of TFLint |
| `checkov-args` | `string` | No | `''` | Extra CLI parameters passed to Checkov scanner |

## Secrets

None. Runs completely offline without cloud credentials.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Read infrastructure code for linting and validation |

## Outputs

None.

## Caller Example

```yaml
name: 'Terraform Checks'

on:
  pull_request:
    paths: ['infra/**']

permissions: {}

jobs:
  static-analysis:
    uses: thesanketkale/reusable-workflows/.github/workflows/terraform-checks.yml@v1
    permissions:
      contents: read
    with:
      working-directory: 'infra'
      terraform-version: '1.9.0'
      use-opentofu: false
```
