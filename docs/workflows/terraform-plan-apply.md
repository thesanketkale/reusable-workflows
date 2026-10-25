# Reusable Workflow: `terraform-plan-apply.yml`

Continuous delivery pipeline for Terraform and OpenTofu infrastructure. Authenticates via OpenID Connect (OIDC) to AWS or Azure, generates execution plans posted as sticky pull request comments, and restricts execution of the apply phase strictly to the `main` branch through protected GitHub Environments with required reviewers.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/terraform-plan-apply.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `cloud` | `string` | **Yes** | N/A | Target cloud provider (`aws` or `azure`) |
| `working-directory` | `string` | No | `'.'` | Directory containing `.tf` files |
| `terraform-version` | `string` | No | `'1.9.0'` | CLI engine version |
| `use-opentofu` | `boolean` | No | `false` | Use OpenTofu CLI if true |
| `environment` | `string` | No | `'production'` | Target GitHub Environment name |
| `aws-role-to-assume` | `string` | No | `''` | AWS IAM Role ARN for OIDC authentication |
| `aws-region` | `string` | No | `'us-east-1'` | Target AWS deployment region |
| `azure-client-id` | `string` | No | `''` | Azure Entra ID application client ID |
| `azure-tenant-id` | `string` | No | `''` | Azure Entra ID tenant ID |
| `azure-subscription-id` | `string` | No | `''` | Azure Subscription ID |

## Secrets

None required. Authentication utilizes short-lived GitHub Actions OIDC tokens.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Read infrastructure code |
| `id-token` | `write` | Required for AWS STS / Azure Entra ID OIDC token exchange |
| `pull-requests` | `write` | Create or update sticky plan comment on pull requests |
| `issues` | `write` | Fallback comment updates |

## Outputs

None.

## Caller Example

```yaml
name: 'Terraform Plan & Apply'

on:
  pull_request:
    paths: ['live/**']
  push:
    branches: ['main']
    paths: ['live/**']

permissions: {}

jobs:
  plan-apply:
    uses: thesanketkale/reusable-workflows/.github/workflows/terraform-plan-apply.yml@v1
    permissions:
      contents: read
      id-token: write
      pull-requests: write
      issues: write
    with:
      cloud: 'aws'
      working-directory: 'live/prod'
      environment: 'production'
      aws-role-to-assume: 'arn:aws:iam::111111111111:role/github-oidc-plan-apply'
      aws-region: 'us-east-1'
```
