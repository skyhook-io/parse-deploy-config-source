# Parse Deploy Config Source

**Internal Action** - Parses deployment configuration source strings.

## Purpose

Parses a deployment source string into repository, ref, and path components for cross-repository deployments.

## Usage

```yaml
- uses: skyhook-io/parse-deploy-config-source@v1
  id: config
  with:
    source: "skyhook-io/k8s-configs@main:services/backend"

# The actual deployment configs are expected at:
# <path>/deploy/overlays/<environment>/
- run: |
    echo "Repository: ${{ steps.config.outputs.repository }}"
    echo "Ref: ${{ steps.config.outputs.ref }}"
    echo "Service path: ${{ steps.config.outputs.path }}"
```

## Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `source` | Config source: `[<repo>][@<ref>][:<path>]` | ✅ |
| `environment` | The deployment environment (e.g., dev, staging, prod) | ❌ |

## Outputs

| Output | Description |
|--------|-------------|
| `repository` | Parsed repository (owner/repo format) |
| `ref` | Parsed git ref (branch or tag) |
| `path` | Parsed path to service/app deployment directory |
| `is_self` | Whether this is the current repository |
| `overlay_dir` | The full path to the overlay directory (only when environment is provided) |
| `is_separate_deploy_repo` | Whether the deployment repo is different from the current repository |

## Source Format

Format: `[<repo>][@<ref>][:<path>]`

All parts are optional and can be omitted:
- `repo`: "self" for current repo, or "owner/repo" (defaults to "self")
- `@ref`: branch/tag (defaults to current ref for self, default branch for others)
- `:path`: path to service/app directory (defaults to ".")

### Directory Structure

The action expects deployment configs to follow this structure:
```
<path>/
└── deploy/
    └── overlays/
        ├── dev/
        ├── staging/
        └── prod/
```

### Examples

| Source | Repository | Ref | Path | Description |
|--------|------------|-----|------|-------------|
| `""` | self (current) | current ref | `.` | All defaults |
| `self` | self (current) | current ref | `.` | Explicit self |
| `@main` | self (current) | main | `.` | Specify ref only |
| `:services/api` | self (current) | current ref | `services/api` | Specify path only |
| `@main:services/api` | self (current) | main | `services/api` | Ref and path |
| `self:services/api` | self (current) | current ref | `services/api` | Repo and path |
| `Acme/configs` | Acme/configs | default branch | `.` | External repo |
| `Acme/configs@v1.2.3` | Acme/configs | v1.2.3 | `.` | External with tag |
| `Acme/configs:services/api` | Acme/configs | default branch | `services/api` | External with path |
| `Acme/configs@main:services/api` | Acme/configs | main | `services/api` | Full specification |

## Note

Internal action used by deploy workflows for cross-repository configurations.