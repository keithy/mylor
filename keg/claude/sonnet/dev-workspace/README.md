# Developer Workspaces

Self-contained Docker containers for different development environments, each configured with mise-en-place tool management.

These *kegs* provide specialized development environments that can be built using the existing doozer-docker workflow.

## Available Workspaces

### Base Workspace (`base/`)
General-purpose development environment with:
- Node.js, Python, Go
- Git, GitHub CLI, Docker
- Basic development tools

### Web Development (`web-dev/`)
Frontend development environment with:
- Node.js ecosystem (pnpm, yarn, bun)
- Modern build tools (Vite, TypeScript, ESLint)
- Browser automation (Playwright)
- React and Vue project templates

### Data Science (`data-science/`)
Scientific computing environment with:
- Python, R, Julia
- Jupyter Lab/Notebook
- ML libraries (scikit-learn, TensorFlow, PyTorch)
- Data analysis tools (pandas, numpy, matplotlib)

### DevOps (`devops/`)
Infrastructure and automation environment with:
- Infrastructure as Code (Terraform, Ansible, Packer)
- Container orchestration (Docker, Kubernetes, Helm)
- Cloud CLIs (AWS, Azure, GCP)
- Security scanning tools

## Building Containers

Use the existing doozer-docker workflow to build containers:

```yaml
# Example workflow dispatch
pipeline: "mylor/keg/claude/sonnet/dev-workspace/web-dev"
ref: "main"
```

## Using the Containers

### Basic Usage

```bash
docker run -it --rm your-registry/dev-workspace:tag
```

### With Volume Mounting

```bash
docker run -it --rm \
  -v $(pwd):/home/dev/workspace \
  -v $HOME/.ssh:/home/dev/.ssh:ro \
  your-registry/dev-workspace:tag
```

### With Port Forwarding (for web-dev)

```bash
docker run -it --rm \
  -p 3000:3000 \
  -p 5173:5173 \
  -v $(pwd):/home/dev/workspace \
  your-registry/dev-workspace:web-dev
```

### With Jupyter (for data-science)

```bash
docker run -it --rm \
  -p 8888:8888 \
  -v $(pwd):/home/dev/workspace \
  your-registry/dev-workspace:data-science

# Inside the container
mise run jupyter-lab
```

## Customizing Workspaces

Each workspace can be customized by:

1. **Modifying mise configuration**: Edit `mise/config.toml` to add/remove tools
2. **Adding bootstrap scripts**: Place scripts in `bootstrap/` directory
3. **Environment variables**: Configure in the mise config or Dockerfile

## Available Tasks

Each workspace comes with predefined mise tasks. List them with:

```bash
mise tasks
```

Run a task with:

```bash
mise run <task-name>
```

## Mise Configuration Structure

```toml
[tools]
# Define tools and their versions
node = "20"
python = "3.12"

[env]
# Environment variables
EDITOR = "vim"

[tasks.task-name]
description = "Task description"
run = '''
  # Task commands
'''
```