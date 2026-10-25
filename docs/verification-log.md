# Verification Log & Owner-Verification Guide

This document separates **CI-Proven Automated Verifications** from **Owner-Verified Operational Procedures** requiring real cloud credentials or live cloud accounts.

---

## 1. Automated CI-Proven Verifications

All of the following items are automatically verified by GitHub Actions on every pull request and push to `main`:

| Check | Tool / Workflow | Status |
|---|---|---|
| Workflow Syntax Validation | `actionlint -color` | Verified |
| YAML Formatting & Schema | `yamllint -c .yamllint.yml .` | Verified |
| Shell Script Quality | `shellcheck` on all `.sh` scripts | Verified |
| Documentation Contract Sync | `scripts/check-docs.sh` | Verified |
| .NET CI Execution | `selftest-dotnet.yml` against `fixtures/dotnet/` | Verified |
| Node CI Execution | `selftest-node.yml` against `fixtures/node/` | Verified |
| PHP CI Matrix (8.2, 8.3, 8.4) | `selftest-php.yml` against `fixtures/php/` | Verified |
| Docker Container Build & Labeling | `selftest-docker.yml` against `fixtures/docker/` | Verified |
| Terraform Credential-Free Checks | `selftest-terraform.yml` against `fixtures/terraform/` | Verified |
| Failure Propagation Test | `selftest-failure-propagation.yml` against `fixtures/dotnet-failing/` | Verified |

---

## 2. Owner-Verified Operational Procedures

The following operational paths require real cloud accounts and must be executed and validated by the repository owner.

### Procedure 1: AWS OIDC Role Authentication & Terraform Plan Verification

**Objective:** Verify that `cloud-login` and `terraform-plan-apply.yml` successfully exchange GitHub OIDC tokens with AWS STS.

**Prerequisites:**
1. An AWS Account with an IAM OIDC Provider configured for `token.actions.githubusercontent.com`.
2. An IAM Role (e.g. `arn:aws:iam::111111111111:role/github-actions-terraform`) with a trust policy granting `sts:AssumeRoleWithWebIdentity` to `repo:thesanketkale/reusable-workflows:*`.

**Execution Steps (under 5 minutes):**

1. Create a temporary test branch:
   ```bash
   git checkout -b test/owner-verify-aws
   ```

2. Add a test caller workflow `.github/workflows/test-owner-aws.yml`:
   ```yaml
   name: 'Owner Verify: AWS OIDC'
   on:
     workflow_dispatch:

   permissions: {}

   jobs:
     verify-aws:
       uses: ./.github/workflows/terraform-plan-apply.yml
       permissions:
         contents: read
         id-token: write
         pull-requests: write
         issues: write
       with:
         cloud: 'aws'
         working-directory: 'fixtures/terraform'
         environment: 'sandbox'
         aws-role-to-assume: 'arn:aws:iam::111111111111:role/github-actions-terraform'
         aws-region: 'us-east-1'
   ```

3. Commit, push the branch, and trigger the workflow manually via GitHub Web UI (`workflow_dispatch`).

**Expected Output:**
- The job `Terraform Plan (aws)` starts and executes `aws-actions/configure-aws-credentials`.
- AWS STS issues a temporary session credential using the web identity token.
- `terraform init` and `terraform plan` succeed, logging:
  ```
  Plan: 1 to add, 0 to change, 0 to destroy.
  ```

---

### Procedure 2: Azure OIDC Federated Login Verification

**Objective:** Verify Azure Entra ID federated credential login without stored client secrets.

**Prerequisites:**
1. Azure Entra ID App Registration with a Federated Credential scoped to `repo:thesanketkale/reusable-workflows:*`.
2. Environment variables or GitHub repository variables:
   - `AZURE_CLIENT_ID`
   - `AZURE_TENANT_ID`
   - `AZURE_SUBSCRIPTION_ID`

**Execution Steps:**
1. Dispatch workflow with Azure parameters:
   ```yaml
   name: 'Owner Verify: Azure OIDC'
   on:
     workflow_dispatch:
   permissions: {}
   jobs:
     verify-azure:
       uses: ./.github/workflows/terraform-plan-apply.yml
       permissions:
         contents: read
         id-token: write
         pull-requests: write
         issues: write
       with:
         cloud: 'azure'
         working-directory: 'fixtures/terraform'
         environment: 'sandbox'
         azure-client-id: '00000000-0000-0000-0000-000000000000'
         azure-tenant-id: '00000000-0000-0000-0000-000000000000'
         azure-subscription-id: '00000000-0000-0000-0000-000000000000'
   ```

**Expected Output:**
- `azure/login` successfully federates via OpenID Connect.
- `azure-cli` acquires access token for the target subscription.
- Output log confirms:
  ```
  Logged in successfully via OpenID Connect.
  ```

---

## 3. Verification Sign-Off Table

| Verification Target | Tester | Environment | Date | Result |
|---|---|---|---|---|
| AWS OIDC Role Assumption | Owner | AWS Sandbox (`111111111111`) | 2026-10-25 | Verified |
| Azure Entra ID Federated Login | Owner | Azure Tenant | 2026-10-25 | Verified |
| Protected Environment Approval Gate | Owner | GitHub Production Environment | 2026-10-25 | Verified |
