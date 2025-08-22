#!/bin/bash

# Weekly Fraggle - Lookout for weekly scheduled builds
# Scans: lighthouse/system.ncl (the horizon)
# Output: Build matrix entries as JSON to stdout

# Source standard fraggle header
here="${BASH_SOURCE%/*}"
source "$here/../fraggle-header.source"

# Define this fraggle's horizon filter
horizon_filter() {
    cat <<EOF
let horizon = import "$HORIZON" in
horizon.pipelines 
|> std.array.filter (fun p => 
    std.record.has_field "schedule" p 
    && p.schedule.type == "weekly"
)
EOF
}

# Setup this fraggle
fraggle_setup "fraggle-weekly"

# Get schedule configuration from lighthouse
weekly_config=$(nickel eval --format json <<< "
  let lighthouse = import \"$LIGHTHOUSE\" in
  lighthouse.schedules.weekly
")

schedule_hour=$(echo "$weekly_config" | jq -r '.hour')
schedule_day=$(echo "$weekly_config" | jq -r '.day')
schedule_enabled=$(echo "$weekly_config" | jq -r '.enabled')

# Current time for schedule checking
current_hour=$(date +%H)
current_day=$(date +%u)  # 1=Monday, 7=Sunday
today_key=$(date +%Y-%m-%d)
week_key=$(date +%Y-W%U)

echo "Weekly fraggle checking schedules at $current_hour:00 on day $current_day ($today_key)" >&2
echo "Configuration: hour=$schedule_hour, day=$schedule_day, enabled=$schedule_enabled" >&2

# Check if weekly builds are enabled
if [[ "$schedule_enabled" != "true" ]]; then
    echo "Weekly builds are disabled" >&2
    echo '[]'
    exit 0
fi

# Filter horizon for weekly scheduled pipelines
weekly_pipelines_json=$(fraggle_filter_horizon "weekly")

echo "Found $(echo "$weekly_pipelines_json" | jq length) weekly pipelines" >&2

# Initialize empty matrix
fraggle_init_matrix

# Check for weekly builds at configured day and hour
if [[ "$current_hour" == "$(printf "%02d" "$schedule_hour")" && "$current_day" == "$schedule_day" ]]; then
    echo "Weekly build time detected" >&2
    
    # Get last weekly build from JSON state
    last_weekly=$(jq -r '.last_weekly // ""' "$STATE_FILE")
    
    echo "Last weekly build: '$last_weekly'" >&2
    
    # Only run if we haven't already done weekly this week
    if [[ "$last_weekly" != "$week_key" ]]; then
        echo "Generating weekly build matrix" >&2
        
        # Generate matrix entries for weekly pipelines
        weekly_matrix=$(echo "$weekly_pipelines_json" | jq --arg today "$today_key" '
          map({
            pipeline: .pipeline,
            trigger: "weekly_build",
            priority: 5, 
            schedule: {
              type: "weekly",
              date: $today,
              hour: ($schedule_hour | tonumber)
            }
          })
        ')
        
        weekly_count=$(echo "$weekly_matrix" | jq length)
        echo "Generated $weekly_count weekly build entries" >&2
        
        # Save to matrix file
        echo "$weekly_matrix" > "$MATRIX_FILE"
        
        # Update JSON state  
        jq --arg week "$week_key" '.last_weekly = $week' "$STATE_FILE" > "$STATE_FILE.tmp"
        mv "$STATE_FILE.tmp" "$STATE_FILE"
        
        echo "Updated state with weekly build completion" >&2
    else
        echo "Weekly build already completed this week: $last_weekly" >&2
    fi
fi

# Output final matrix
fraggle_output_matrix