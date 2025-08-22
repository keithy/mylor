#!/usr/bin/env bash
# test_helper.sh - bash-spec test helpers for fraggle-cron tests

# Custom matchers for bash-spec
to_be_valid_json() {
    local actual="$1"
    echo "$actual" | jq . >/dev/null 2>&1
}

to_exist() {
    local file_path="$1" 
    [[ -e "$file_path" ]]
}

to_contain() {
    local actual="$1"
    local expected="$2"
    echo "$actual" | grep -q "$expected"
}

to_equal() {
    local actual="$1"
    local expected="$2"
    [[ "$actual" == "$expected" ]]
}

# Test utilities
create_minimal_harbour_config() {
    cat << 'EOF'
{
  harbour = {
    harbour_name = "test-harbour",
    container_types = [| 'keg, 'sack |],
    default_check_interval = 60,
  },
  lighthouse = {
    check_interval = 30,
    max_concurrent_checks = 3,
    github_api_timeout = 30,
    notification_channels = [],
  },
  pipelines = [
    {
      pipeline = "keg/test/nightly",
      triggers = ["nightly_build"],
      order = 1,
    },
    {
      pipeline = "sack/test/weekly", 
      triggers = ["weekly_build"],
      order = 2,
    }
  ],
}
EOF
}

create_empty_state() {
    mkdir -p .fraggle-state
    cat > .fraggle-state/fraggle-state.ncl << 'EOF'
let state_types = import "./fraggle-state.ncl" in
state_types.empty_state
EOF
}

create_state_with_nightly() {
    local date="$1"
    mkdir -p .fraggle-state
    cat > .fraggle-state/fraggle-state.ncl << EOF
let state_types = import "./fraggle-state.ncl" in
{
  last_nightly = "$date",
  build_history = [],
} | state_types.FraggleState
EOF
}

create_state_with_weekly() {
    local week="$1"
    mkdir -p .fraggle-state
    cat > .fraggle-state/fraggle-state.ncl << EOF
let state_types = import "./fraggle-state.ncl" in
{
  last_weekly = "$week",
  build_history = [],
} | state_types.FraggleState
EOF
}

# Export functions for bash-spec
export -f to_be_valid_json
export -f to_exist
export -f to_contain
export -f to_equal
export -f create_minimal_harbour_config
export -f create_empty_state
export -f create_state_with_nightly
export -f create_state_with_weekly