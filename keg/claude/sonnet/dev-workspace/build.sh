#!/usr/bin/env bash
set -euo pipefail

# Build script for developer workspace containers
# Uses the existing doozer-docker workflow

REGISTRY="${REGISTRY:-}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

workspaces=("base" "web-dev" "data-science" "devops")

build_workspace() {
    local workspace="$1"
    local image_name="dev-workspace-${workspace}"
    local full_path="mylor/keg/claude/sonnet/dev-workspace/${workspace}"
    
    echo "Building ${image_name}:${IMAGE_TAG}..."
    
    if [ -n "$REGISTRY" ]; then
        tag="${REGISTRY}/${image_name}:${IMAGE_TAG}"
    else
        tag="${image_name}:${IMAGE_TAG}"
    fi
    
    docker build -t "$tag" "$full_path"
    echo "Built: $tag"
}

if [ $# -eq 0 ]; then
    echo "Building all workspaces..."
    for workspace in "${workspaces[@]}"; do
        build_workspace "$workspace"
    done
else
    workspace="$1"
    if [[ " ${workspaces[*]} " == *" $workspace "* ]]; then
        build_workspace "$workspace"
    else
        echo "Unknown workspace: $workspace"
        echo "Available workspaces: ${workspaces[*]}"
        exit 1
    fi
fi

echo "Build complete!"