# Configuration for Charm Crush pipeline
# Created by Claude Code from research on:
# - charmbracelet/crush GitHub repository structure and build process
# - Go version requirements (Task-based builds, GoReleaser setup)
# - Nightly build patterns and CI/CD practices
# - Container configuration best practices for Go applications
# - System dependencies and multi-platform build targets
{
  # Available resources to watch
  resources = {
    main_branch = {
      type = 'github,
      owner = "charmbracelet",
      repo = "crush",
      branch = "main",
      track = 'commits,
      file_filter = ["**/*.go", "go.mod", "go.sum", "Dockerfile", "Taskfile.yaml"],
    },
    
    releases = {
      type = 'github,
      owner = "charmbracelet",
      repo = "crush",
      track = 'releases,
    },
    
    develop_branch = {
      type = 'github,
      owner = "charmbracelet",
      repo = "crush",
      branch = "develop",
      track = 'commits,
      file_filter = ["**/*.go", "go.mod", "go.sum"],
    },
  },
  
  # Build configuration for Crush
  build_config = {
    go_version = "1.22",
    targets = ["linux/amd64", "linux/arm64", "darwin/amd64", "darwin/arm64", "windows/amd64"],
    test_commands = [
      "go test ./...", 
      "go vet ./...",
      "golangci-lint run",
    ],
    build_commands = [
      "task build",
      "task test",
    ],
    artifacts = [
      "dist/*",
    ],
  },
  
  # Container configuration
  container_config = {
    base_image = "golang:1.22-alpine",
    build_args = {
      VERSION = "$GITHUB_SHA",
      BUILD_DATE = "$BUILD_DATE",
    },
    labels = {
      "org.opencontainers.image.source" = "https://github.com/charmbracelet/crush",
      "org.opencontainers.image.title" = "Crush",
      "org.opencontainers.image.description" = "The glamourous AI coding agent for your favourite terminal",
    },
  },
  
  # Nightly build configuration
  schedule = {
    nightly = {
      cron = "0 2 * * *",  # 2 AM UTC daily
      timezone = "UTC",
      source = resources.main_branch,
    },
  },
}