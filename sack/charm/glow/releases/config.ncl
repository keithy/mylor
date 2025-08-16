# Configuration for Charm Glow pipeline
# Created by Claude Code from research on:
# - charmbracelet/glow GitHub repository structure and build process
# - Go version requirements for markdown rendering
# - Multi-platform build targets for terminal applications
# - Documentation rendering and testing patterns
{
  # Available resources to watch
  resources = {
    main_branch = {
      type = 'github,
      owner = "charmbracelet", 
      repo = "glow",
      branch = "master",
      track = 'commits,
      file_filter = ["**/*.go", "go.mod", "go.sum", "**/*.md"],
    },
    
    releases = {
      type = 'github,
      owner = "charmbracelet",
      repo = "glow",
      track = 'releases,
    },
  },
  
  # Build configuration for Glow
  build_config = {
    go_version = "1.22",
    targets = ["linux/amd64", "linux/arm64", "darwin/amd64", "darwin/arm64", "windows/amd64"],
    test_commands = [
      "go test ./...",
      "go vet ./...",
      "go build -o glow .",
    ],
    demo_commands = [
      "glow README.md --style auto",
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
      "org.opencontainers.image.source" = "https://github.com/charmbracelet/glow",
      "org.opencontainers.image.title" = "Glow",
      "org.opencontainers.image.description" = "Render markdown on the CLI, with pizzazz!",
    },
  },
}