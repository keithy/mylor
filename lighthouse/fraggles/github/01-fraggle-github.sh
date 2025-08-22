#!/bin/bash
set -euo pipefail

# GitHub Fraggle - Monitors GitHub repositories for changes
# Input: Complete harbour system config via stdin
# Output: Build matrix entries as JSON to stdout

STATE_DIR=".fraggle-state"
STATE_FILE="$STATE_DIR/fraggle-github.json"
MATRIX_FILE="$STATE_DIR/github-matrix.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Initialize empty state if not exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo '{}' > "$STATE_FILE"
fi

# Read harbour config from stdin
CONFIG=$(cat)

# Extract GitHub resources from config
echo "$CONFIG" | jq -c '.pipelines[]? | select(.github_resources[]?.type == "github") | {
    pipeline: .pipeline,
    github_resources: [.github_resources[] | select(.type == "github")]
}' | while IFS= read -r pipeline_config; do
    pipeline=$(echo "$pipeline_config" | jq -r '.pipeline')
    
    # Process each GitHub resource for this pipeline
    echo "$pipeline_config" | jq -c '.github_resources[]' | while IFS= read -r resource; do
        owner=$(echo "$resource" | jq -r '.owner')
        repo=$(echo "$resource" | jq -r '.repo')
        branch=$(echo "$resource" | jq -r '.branch // "main"')
        track=$(echo "$resource" | jq -r '.track // "commits"')
        
        resource_key="${owner}/${repo}#${branch}"
        
        # Get last known state
        last_sha=$(jq -r --arg key "$resource_key" '.[$key] // ""' "$STATE_FILE")
        
        # Check GitHub API for latest commit
        api_url="https://api.github.com/repos/${owner}/${repo}/commits/${branch}"
        current_sha=$(curl -s -H "Accept: application/vnd.github.v3+json" "$api_url" | jq -r '.sha // ""')
        
        # If SHA changed, add to build matrix
        if [[ -n "$current_sha" && "$current_sha" != "$last_sha" ]]; then
            echo "Change detected in $resource_key: $last_sha -> $current_sha" >&2
            
            # Create matrix entry
            matrix_entry=$(jq -n \
                --arg pipeline "$pipeline" \
                --arg trigger "github_commit" \
                --arg owner "$owner" \
                --arg repo "$repo" \
                --arg branch "$branch" \
                --arg commit_sha "$current_sha" \
                --arg previous_sha "$last_sha" \
                --argjson priority 5 \
                '{
                    pipeline: $pipeline,
                    trigger: $trigger,
                    priority: $priority,
                    github: {
                        owner: $owner,
                        repo: $repo,
                        branch: $branch,
                        commit_sha: $commit_sha,
                        previous_sha: $previous_sha
                    }
                }'
            )
            
            # Append to matrix file
            echo "$matrix_entry" >> "$MATRIX_FILE"
            
            # Update state
            jq --arg key "$resource_key" --arg sha "$current_sha" '.[$key] = $sha' "$STATE_FILE" > "$STATE_FILE.tmp"
            mv "$STATE_FILE.tmp" "$STATE_FILE"
        fi
    done
done

# Output collected matrix entries
if [[ -f "$MATRIX_FILE" ]]; then
    jq -s '.' "$MATRIX_FILE"
    rm "$MATRIX_FILE"  # Clean up temp file
else
    echo '[]'  # No changes detected
fi