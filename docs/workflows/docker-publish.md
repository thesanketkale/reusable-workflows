# Reusable Workflow: `docker-publish.yml`

Hardened container build and publication pipeline using Docker Buildx, GitHub Container Registry (GHCR), multi-platform emulation via QEMU, metadata labeling, and cryptographic build provenance and SBOM attestations.

## Workflow Reference

```yaml
uses: thesanketkale/reusable-workflows/.github/workflows/docker-publish.yml@v1
```

## Inputs

| Name | Type | Required | Default | Description |
|---|---|---|---|---|
| `image-name` | `string` | **Yes** | N/A | Target container image name (e.g. `ghcr.io/thesanketkale/my-service`) |
| `registry` | `string` | No | `'ghcr.io'` | Container registry host |
| `dockerfile` | `string` | No | `'Dockerfile'` | Relative path to Dockerfile |
| `context` | `string` | No | `'.'` | Docker build context directory |
| `push` | `boolean` | No | `true` | Whether to publish image to registry |
| `platforms` | `string` | No | `'linux/amd64'` | Target platforms (comma-separated, e.g. `linux/amd64,linux/arm64`) |
| `tags` | `string` | No | `''` | Optional custom tag patterns |

## Secrets

None required. Uses `${{ github.token }}` for GHCR registry authentication.

## Permissions

| Scope | Permission | Justification |
|---|---|---|
| `contents` | `read` | Read source repository and Dockerfile |
| `packages` | `write` | Publish container images to GitHub Packages / GHCR |
| `id-token` | `write` | Cryptographic signature exchange for provenance & SBOM attestations |
| `attestations` | `write` | Store signed attestations in GitHub Attestation service |

## Outputs

| Name | Description |
|---|---|
| `image-digest` | SHA-256 digest of published container image |
| `image-tags` | Comma-separated list of generated image tags |

## Caller Example

```yaml
name: 'Publish Image'

on:
  push:
    tags: ['v*']

permissions: {}

jobs:
  container:
    uses: thesanketkale/reusable-workflows/.github/workflows/docker-publish.yml@v1
    permissions:
      contents: read
      packages: write
      id-token: write
      attestations: write
    with:
      image-name: 'ghcr.io/thesanketkale/web-api'
      platforms: 'linux/amd64,linux/arm64'
      push: true
```
