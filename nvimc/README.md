## nvimc: A Containerized IDE Based on Neovim

nvimc provides portable, reproducible development environments packaged as Docker containers. Each container includes Neovim v0.11.1 with pre-configured plugins, language servers, and development tools.

**Base**: Ubuntu 24.04
**Registry**: [tsuchiya55docker/nvimc](https://hub.docker.com/r/tsuchiya55docker/nvimc)
**Architecture**: Multi-architecture support (ARM64 and AMD64)

### Available Images

| Image | Architecture | Use Case | Includes |
|-------|--------------|----------|----------|
| `default-arm` | linux/arm64 | ARM development (M1/M2 Macs) | Neovim, Node.js 24.x, .NET 8.0 |
| `default-amd` | linux/amd64 | AMD/Intel development | Neovim, Node.js 24.x, .NET 8.0 |
| `python` | linux/arm64 | Python development | Above + basedpyright, ruff, pyright |

**Current Version**: `0.0.2` (see [Taskfile.yml](Taskfile.yml))

### CI/CD

#### Build Status

[![nvimc Build](https://github.com/shunsock/dotfiles/actions/workflows/nvimc-build.yml/badge.svg)](https://github.com/shunsock/dotfiles/actions/workflows/nvimc-build.yml)
[![nvimc Deploy](https://github.com/shunsock/dotfiles/actions/workflows/nvimc-deploy.yml/badge.svg)](https://github.com/shunsock/dotfiles/actions/workflows/nvimc-deploy.yml)

#### Workflows

**1. Build Workflow** (`nvimc-build.yml`)
- **Trigger**: Automatic on pull requests affecting `nvimc/` directory
- **Purpose**: Validate Docker image builds without pushing
- **Images**: Builds all 3 images in parallel
- **Caching**: Uses GitHub Actions cache for faster builds

**2. Deploy Workflow** (`nvimc-deploy.yml`)
- **Trigger**: Manual (workflow_dispatch) from GitHub Actions tab
- **Purpose**: Build and push versioned images to Docker Hub
- **Images**: Deploys all 3 images with version and latest tags
- **Authentication**: Requires Docker Hub secrets (see below)

#### Deployment Process

To deploy a new version:

1. **Update Version**
   ```bash
   # Edit nvimc/Taskfile.yml
   # Update VERSION variable (line 4)
   VERSION: 0.0.3  # Bump version
   ```

2. **Create Pull Request**
   - Commit version change
   - Open PR to main branch
   - Build workflow validates images

3. **Merge and Deploy**
   - Merge PR to main
   - Navigate to [Actions tab](https://github.com/shunsock/dotfiles/actions/workflows/nvimc-deploy.yml)
   - Click "Run workflow" button
   - Select `main` branch
   - Click "Run workflow" to start deployment

4. **Verify Deployment**
   - Check workflow logs for success
   - Verify images on [Docker Hub](https://hub.docker.com/r/tsuchiya55docker/nvimc/tags)
   - Pull and test: `docker pull tsuchiya55docker/nvimc:default-arm-0.0.3`

#### Docker Hub Authentication

The deploy workflow requires GitHub Secrets for Docker Hub authentication:

1. **Generate Access Token**
   - Visit [Docker Hub Security Settings](https://hub.docker.com/settings/security)
   - Click "New Access Token"
   - Name: `github-actions-nvimc`
   - Permissions: Read & Write
   - Copy token (shown only once)

2. **Configure GitHub Secrets**
   - Repository Settings > Secrets and variables > Actions
   - Add `DOCKER_USERNAME`: Your Docker Hub username
   - Add `DOCKER_PASSWORD`: Access token from step 1

3. **Verify Configuration**
   - Run deploy workflow
   - Check logs for successful Docker Hub login

#### Version Management

- **Source of Truth**: `nvimc/Taskfile.yml` line 4
- **Format**: `VERSION: X.Y.Z` (semantic versioning)
- **Extraction**: Deploy workflow reads VERSION automatically
- **Tags**: Each image receives two tags:
  - Version tag: `<image-name>-<version>` (e.g., `python-0.0.2`)
  - Latest tag: `<image-name>-latest` (e.g., `python-latest`)

### Local Development

#### Building Images

```bash
cd nvimc/

# Build individual images
task build:default:arm    # ARM architecture
task build:default:amd    # AMD/Intel architecture
task build:python         # Python development environment
```

#### Running Containers

```bash
# Run with current directory as workspace
task run:default:arm .
task run:default:amd .
task run:python .

# Run with specific directory
task run:python /path/to/your/project
```

**Persistent Data**: Neovim configuration, plugins, and cache are stored in:
- `~/.config/nvimc/<container>/share` - Plugin data
- `~/.config/nvimc/<container>/cache` - Cache files
- `~/.config/nvimc/<container>/state` - State files

#### Pushing to Registry

```bash
# Push all images (requires Docker Hub authentication)
task push

# Push individual images
task push:python
task push:default:arm
task push:default:amd
```

**Authentication**: Login to Docker Hub first:
```bash
docker login
# Enter username and password/access token
```

### Architecture

**Multi-stage Builds**: All images use builder/runtime pattern for smaller final images

**Base Images**:
- Builder stage: Ubuntu 24.04 with build tools
- Runtime stage: Ubuntu 24.04 minimal

**Shared Components**:
- Neovim v0.11.1 (from official releases)
- Node.js 24.x (from NodeSource)
- .NET 8.0 SDK (for Marksman LSP)
- Git, ripgrep, fd-find, build-essential

**Python Image Additions**:
- basedpyright (Python type checker)
- ruff (Python linter/formatter)
- pyright (Node-based Python LSP)
- python3-venv (virtual environment support)

**Configuration**: Neovim configs copied from `nvimc-*/config/` directories

### Contributing

#### Version Bump Process

1. Update `VERSION` in `Taskfile.yml`
2. Test builds locally: `task build:default:arm build:default:amd build:python`
3. Create PR (triggers build workflow)
4. After merge, deploy from Actions tab

#### Testing Requirements

Before submitting PR:
- All three images must build successfully
- Test basic Neovim functionality in each container
- Verify language servers work (run `:checkhealth` in Neovim)

#### Dockerfile Changes

When modifying Dockerfiles:
- Maintain multi-stage build pattern
- Keep builder stage clean (only build dependencies)
- Copy only necessary files to runtime stage
- Update this README if adding new features/tools
