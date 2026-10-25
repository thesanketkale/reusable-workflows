# Security Architecture & OIDC Federation Guide

This document outlines the security architecture of `reusable-workflows`, focusing on OpenID Connect (OIDC) identity federation, credential-less cloud authentication, token scoping, and the elimination of `pull_request_target` risks.

---

## 1. Cloud Authentication via OpenID Connect (OIDC)

Static long-lived cloud credentials (such as AWS IAM access keys or Azure service principal passwords) are high-value targets for credential compromise. `reusable-workflows` eliminates static credentials entirely by using GitHub's OIDC Identity Provider (`token.actions.githubusercontent.com`).

### 1.1 AWS IAM Trust Policy Configuration

To allow GitHub Actions to assume an IAM Role in your AWS account without credentials:

1. **OIDC Identity Provider Setup:**
   Ensure an IAM OIDC Identity Provider exists in your AWS account with:
   - **Provider URL:** `https://token.actions.githubusercontent.com`
   - **Audience:** `sts.amazonaws.com`

2. **IAM Role Trust Relationship:**
   Scope the trust relationship strictly to your repository and target environment or branch. Never use open wildcards (`*`) for repository names:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::111111111111:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:thesanketkale/*:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

---

### 1.2 Azure Entra ID Federated Credentials Setup

To authenticate to Microsoft Azure without storing client secrets:

1. Register an App Registration in Microsoft Entra ID.
2. Under **Certificates & secrets** > **Federated credentials**, create a new federated credential:
   - **Federated credential scenario:** GitHub Actions deploying Azure resources
   - **Organization:** `thesanketkale` (or your GitHub organization)
   - **Repository:** `my-downstream-repo`
   - **Entity type:** `Environment` (e.g. `production`) or `Branch` (`main`)
   - **Audience:** `api://AzureADTokenExchange`
3. Assign appropriate Azure RBAC roles (such as `Reader` for plan jobs, or `Contributor` scoped to specific resource groups for apply jobs).

---

## 2. Why `pull_request_target` is Strictly Avoided

The `pull_request_target` event triggers in the context of the base branch of the pull request rather than the merge commit. This grants the workflow run access to repository secrets and write tokens even when initiated from an external fork.

### Vulnerabilities of `pull_request_target`:
1. **Pwn-Request Attacks:** If a workflow checks out the untrusted fork's code (`actions/checkout` with `ref: ${{ github.event.pull_request.head.sha }}`) and executes build scripts (`npm run build`, `make`), an attacker can execute arbitrary code inside a runner that has access to write tokens and cloud credentials.
2. **Context Injection:** Interpolating `${{ github.event.pull_request.title }}` or head branch names into shell strings enables script injection.

### Standard Defense in `reusable-workflows`:
- Workflows exclusively trigger on `pull_request` (running with read-only tokens and without access to repository environment secrets).
- Operations requiring elevated credentials (such as Terraform apply, image publishing, or cloud deployment) are strictly restricted to the `push` event on protected branches (`main`) or via gated GitHub Environments requiring manual review.

---

## 3. Token Permissions Model

Every reusable workflow enforces zero ambient trust by defaulting to an empty permissions object:
```yaml
permissions: {}
```

Individual jobs declare only the exact scopes necessary:

```yaml
permissions:
  contents: read           # Clone and checkout code
  id-token: write          # Request OIDC tokens from GitHub token service
  pull-requests: write     # Post or update sticky plan comments
```

---

## 4. Supply Chain Defense

- **SHA Pinning:** Every third-party action is pinned to an immutable 40-character commit SHA with a version comment.
- **Dependabot Automation:** Dependabot scans pinned actions and opens automated PRs with changelog diffs.
- **CodeQL & Gitleaks:** Automated static analysis and secret detection run continuously across all branches and commits.
