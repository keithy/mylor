#!/bin/bash
set -euo pipefail

# Cron Fraggle - Handles scheduled builds (nightly, weekly, etc.)
# Input: Complete harbour system config via stdin
# Output: Build matrix entries as JSON to stdout

STATE_DIR=".fraggle-state"
STATE_FILE="$STATE_DIR/fraggle-cron.json"
MATRIX_FILE="$STATE_DIR/cron-matrix.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Initialize empty state if not exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo '{}' > "$STATE_FILE"
fi

# Read harbour config from stdin
CONFIG=$(cat)

# Current time for schedule checking
current_hour=$(date +%H)
current_day=$(date +%u)  # 1=Monday, 7=Sunday
today_key=$(date +%Y-%m-%d)

# Check if it's nightly build time (2 AM UTC)
if [[ "$current_hour" == "02" ]]; then
    echo "Nightly build time detected" >&2
    
    # Get last nightly build date
    last_nightly=$(jq -r '.last_nightly // ""' "$STATE_FILE")
    
    # Only run if we haven't already done nightly today
    if [[ "$last_nightly" != "$today_key" ]]; then
        echo "Generating nightly build matrix" >&2
        
        # Extract all pipelines for nightly builds
        echo "$CONFIG" | jq -c '.pipelines[]?' | while IFS= read -r pipeline_config; do
            pipeline=$(echo "$pipeline_config" | jq -r '.pipeline')
            
            # Create nightly build matrix entry
            matrix_entry=$(jq -n \
                --arg pipeline "$pipeline" \
                --arg trigger "nightly_build" \
                --arg date "$today_key" \
                --argjson priority 8 \
                '{
                    pipeline: $pipeline,
                    trigger: $trigger,
                    priority: $priority,
                    schedule: {
                        type: "nightly",
                        date: $date,
                        hour: 2
                    }
                }'
            )
            
            echo "$matrix_entry" >> "$MATRIX_FILE"
        done
        
        # Update state
        jq --arg date "$today_key" '.last_nightly = $date' "$STATE_FILE" > "$STATE_FILE.tmp"
        mv "$STATE_FILE.tmp" "$STATE_FILE"
    else
        echo "Nightly build already completed today: $last_nightly" >&2
    fi
fi

# Output collected matrix entries
if [[ -f "$MATRIX_FILE" ]]; then
    jq -s '.' "$MATRIX_FILE"
    rm "$MATRIX_FILE"  # Clean up temp file
else
    echo '[]'  # No scheduled builds needed
fi