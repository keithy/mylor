#!/bin/bash

# Nightly Fraggle - Lookout for nightly scheduled builds
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
    && p.schedule.type == "nightly"
)
EOF
}

# Setup this fraggle
fraggle_setup "fraggle-nightly"

# Get schedule configuration from lighthouse
nightly_config=$(nickel eval --format json <<< "
  let lighthouse = import \"$LIGHTHOUSE\" in
  lighthouse.schedules.nightly
")

schedule_hour=$(echo "$nightly_config" | jq -r '.hour')
schedule_enabled=$(echo "$nightly_config" | jq -r '.enabled')
skip_weekends=$(echo "$nightly_config" | jq -r '.skip_weekends // false')

# Current time for schedule checking
current_hour=$(date +%H)
current_day=$(date +%u)  # 1=Monday, 7=Sunday
today_key=$(date +%Y-%m-%d)

echo "Nightly fraggle checking schedules at $current_hour:00 on day $current_day ($today_key)" >&2
echo "Configuration: hour=$schedule_hour, enabled=$schedule_enabled, skip_weekends=$skip_weekends" >&2

# Check if nightly builds are enabled
if [[ "$schedule_enabled" != "true" ]]; then
    echo "Nightly builds are disabled" >&2
    echo '[]'
    exit 0
fi

# Check if we should skip weekends
if [[ "$skip_weekends" == "true" && ("$current_day" == "6" || "$current_day" == "7") ]]; then
    echo "Skipping nightly build on weekend (day $current_day)" >&2
    echo '[]'
    exit 0
fi

# Filter horizon for nightly scheduled pipelines
nightly_pipelines_json=$(fraggle_filter_horizon "nightly")

echo "Found $(echo "$nightly_pipelines_json" | jq length) nightly pipelines" >&2

# Initialize empty matrix
fraggle_init_matrix

# Check for nightly builds at configured hour
if [[ "$current_hour" == "$(printf "%02d" "$schedule_hour")" ]]; then
    echo "Nightly build time detected" >&2
    
    # Get last nightly build date from JSON state
    last_nightly=$(jq -r '.last_nightly // ""' "$STATE_FILE")
    
    echo "Last nightly build: '$last_nightly'" >&2
    
    # Only run if we haven't already done nightly today
    if [[ "$last_nightly" != "$today_key" ]]; then
        echo "Generating nightly build matrix" >&2
        
        # Generate matrix entries for nightly pipelines
        nightly_matrix=$(echo "$nightly_pipelines_json" | jq --arg today "$today_key" '
          map({
            pipeline: .pipeline,
            trigger: "nightly_build", 
            priority: 8,
            schedule: {
              type: "nightly",
              date: $today,
              hour: ($schedule_hour | tonumber)
            }
          })
        ')
        
        nightly_count=$(echo "$nightly_matrix" | jq length)
        echo "Generated $nightly_count nightly build entries" >&2
        
        # Save to matrix file
        echo "$nightly_matrix" > "$MATRIX_FILE"
        
        # Update JSON state
        jq --arg date "$today_key" '.last_nightly = $date' "$STATE_FILE" > "$STATE_FILE.tmp"
        mv "$STATE_FILE.tmp" "$STATE_FILE"
        
        echo "Updated state with nightly build completion" >&2
    else
        echo "Nightly build already completed today: $last_nightly" >&2
    fi
fi

# Output final matrix
fraggle_output_matrix