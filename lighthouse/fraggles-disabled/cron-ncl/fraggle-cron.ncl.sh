#!/bin/bash
set -euo pipefail

# Cron Fraggle - Handles scheduled builds (nightly, weekly, etc.) using Nickel state management
# Input: Complete harbour system config via stdin
# Output: Build matrix entries as JSON to stdout

STATE_DIR=".fraggle-state"
STATE_FILE="$STATE_DIR/fraggle-state.ncl"
MATRIX_FILE="$STATE_DIR/cron-matrix.json"
TEMP_CONFIG_FILE="$STATE_DIR/temp-config.ncl"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Initialize empty Nickel state if not exists
if [[ ! -f "$STATE_FILE" ]]; then
    echo "Initializing empty fraggle state" >&2
    cat > "$STATE_FILE" << 'EOF'
let state_types = import "./fraggle-state.ncl" in
state_types.empty_state
EOF
fi

# Read harbour config from stdin and save as temporary Nickel file
CONFIG=$(cat)
echo "let config_data = $CONFIG in config_data" > "$TEMP_CONFIG_FILE"

# Current time for schedule checking
current_hour=$(date +%H)
current_day=$(date +%u)  # 1=Monday, 7=Sunday
today_key=$(date +%Y-%m-%d)

echo "Checking schedules at hour $current_hour, day $current_day, date $today_key" >&2

# Check if it's nightly build time (2 AM UTC)
if [[ "$current_hour" == "02" ]]; then
    echo "Nightly build time detected" >&2
    
    # Get last nightly build date using Nickel
    echo "let state = import \"$STATE_FILE\" in match state.last_nightly with | null => \"\" | date => date" > temp_query.ncl
    last_nightly=$(nickel export --format json temp_query.ncl | jq -r '.')
    rm -f temp_query.ncl
    
    echo "Last nightly build: '$last_nightly'" >&2
    
    # Only run if we haven't already done nightly today
    if [[ "$last_nightly" != "$today_key" ]]; then
        echo "Generating nightly build matrix" >&2
        
        # Generate nightly build matrix using Nickel
        nickel eval --format json <<< "
            let config = import \"$TEMP_CONFIG_FILE\" in
            let state_types = import \"./fraggle-state.ncl\" in
            
            let matrix_entries = 
                config.pipelines
                |> std.array.filter_map (fun pipeline_config =>
                    if std.record.has_field \"pipeline\" pipeline_config then
                        {
                            pipeline = pipeline_config.pipeline,
                            trigger = 'nightly_build,
                            priority = 8,
                            schedule = {
                                type = 'nightly,
                                date = \"$today_key\",
                                hour = 2,
                            }
                        } | state_types.MatrixEntry | Some
                    else None
                ) in
            matrix_entries
        " > "$MATRIX_FILE"
        
        echo "Generated $(jq length "$MATRIX_FILE") nightly build entries" >&2
        
        # Update state using Nickel
        nickel eval --format json <<< "
            let state = import \"$STATE_FILE\" in
            let state_types = import \"./fraggle-state.ncl\" in
            let updated_history = state.build_history @ [{
                date = \"$today_key\",
                trigger = 'nightly_build,
                pipelines = (import \"$TEMP_CONFIG_FILE\").pipelines |> std.array.map (fun p => p.pipeline),
            }] in
            
            state & {
                last_nightly = \"$today_key\",
                build_history = updated_history,
            } | state_types.FraggleState
        " > "$STATE_FILE.tmp"
        mv "$STATE_FILE.tmp" "$STATE_FILE"
        
        echo "Updated state with nightly build completion" >&2
    else
        echo "Nightly build already completed today: $last_nightly" >&2
        echo '[]' > "$MATRIX_FILE"
    fi
else
    echo "Not nightly build time (current hour: $current_hour)" >&2
    echo '[]' > "$MATRIX_FILE"
fi

# Check for weekly builds (Sunday at 3 AM UTC)
if [[ "$current_hour" == "03" && "$current_day" == "7" ]]; then
    echo "Weekly build time detected" >&2
    
    # Get last weekly build date using Nickel  
    last_weekly=$(nickel eval --format json <<< "
        let state = import \"$STATE_FILE\" in
        match state.last_weekly with
          | null => \"\"
          | date => date
    " | jq -r '.')
    
    week_key=$(date +%Y-W%U)  # Year-WeekNumber format
    
    if [[ "$last_weekly" != "$week_key" ]]; then
        echo "Generating weekly build matrix" >&2
        
        # Generate weekly build matrix using Nickel and append to existing matrix
        weekly_matrix=$(nickel eval --format json <<< "
            let config = import \"$TEMP_CONFIG_FILE\" in
            let state_types = import \"./fraggle-state.ncl\" in
            
            config.pipelines
            |> std.array.filter_map (fun pipeline_config =>
                if std.record.has_field \"pipeline\" pipeline_config then
                    {
                        pipeline = pipeline_config.pipeline,
                        trigger = 'weekly_build,
                        priority = 5,
                        schedule = {
                            type = 'weekly,
                            date = \"$today_key\",
                            hour = 3,
                        }
                    } | state_types.MatrixEntry | Some
                else None
            )
        ")
        
        # Merge with existing matrix
        jq -s '.[0] + .[1]' "$MATRIX_FILE" <<< "$weekly_matrix" > "$MATRIX_FILE.tmp"
        mv "$MATRIX_FILE.tmp" "$MATRIX_FILE"
        
        # Update weekly state
        nickel eval --format json <<< "
            let state = import \"$STATE_FILE\" in
            let state_types = import \"./fraggle-state.ncl\" in
            
            state & {
                last_weekly = \"$week_key\",
            } | state_types.FraggleState
        " > "$STATE_FILE.tmp"
        mv "$STATE_FILE.tmp" "$STATE_FILE"
        
        echo "Generated weekly builds and updated state" >&2
    else
        echo "Weekly build already completed this week: $last_weekly" >&2
    fi
fi

# Output collected matrix entries
if [[ -f "$MATRIX_FILE" ]]; then
    cat "$MATRIX_FILE"
    rm -f "$MATRIX_FILE"  # Clean up temp file
else
    echo '[]'  # No scheduled builds needed
fi

# Clean up temporary config file
rm -f "$TEMP_CONFIG_FILE"