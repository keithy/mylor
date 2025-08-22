#!/usr/bin/env bash
# fraggle_cron_spec.sh - keithy/bash-spec-2 tests for fraggle-cron.ncl.sh

# script is run in its own directory
# Test utilities
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$COVE/cove-specs/bash-spec-cove.sh"

FRAGGLE_SCRIPT="$here/fraggle-cron.ncl.sh" 
SAMPLE_CONFIG="$here/test-fixtures/sample-harbour-config.ncl"

run_fraggle() {
    echo "$SAMPLE_JSON" | "$FRAGGLE_SCRIPT" 2>/dev/null
}

describe "fraggle-cron.ncl.sh scheduler" && {
  
  context "nightly build scheduling at 2 AM UTC" && {
    
    it "generates nightly build matrix when no previous build today" && {
      setup_test 01
      mock_date "2024-08-15" "02" "4"  # Thursday 2 AM
      
      result=$(run_fraggle)
      nightly_count=$(jq_count_entries_kv trigger nightly_build "$result")
      
      expect "$nightly_count" to_be "3"
      expect "$result" to_match "nightly_build"
      expect "$result" to_match "priority.*8"
      
      # Check state was updated
      expect ".fraggle-state/fraggle-state.ncl" to_exist
      expect "$(cat .fraggle-state/fraggle-state.ncl)" to_match "last_nightly.*2024-08-15"
      
      teardown_test
    }

    it "skips nightly build when already completed today"  && {
      setup_test 02
      mock_date "2024-08-15" "02" "4"
      
      # Pre-populate state with today's date
      mkdir -p .fraggle-state
      cat > .fraggle-state/fraggle-state.ncl << 'EOF'
let state_types = import "./fraggle-state.ncl" in
{
  last_nightly = "2024-08-15",
  build_history = [],
} | state_types.FraggleState
EOF
      
      result=$(run_fraggle)
      
      expect "$result" to_be "[]"
      teardown_test
    }

    it "does nothing outside nightly build hours"  && {
      setup_test 03
      mock_date "2024-08-15" "10" "4"  # Thursday 10 AM
      
      result=$(run_fraggle)
      
      expect "$result" to_be "[]"
      teardown_test
    }
  }

  context "weekly build scheduling at 3 AM Sunday"  && {
    
    it "generates weekly build matrix when no previous build this week"  && {
      setup_test 04
      mock_date "2024-08-18" "03" "7"  # Sunday 3 AM
      
      result=$(run_fraggle)
      weekly_count=$(jq_count_entries_kv trigger weekly_build "$result")
      
      expect "$weekly_count" to_be "3"
      expect "$result" to_match "weekly_build"
      expect "$result" to_match "priority.*5"
      
      # Check state was updated
      expect "$(cat .fraggle-state/fraggle-state.ncl)" to_match "last_weekly.*2024-W33"
      
      teardown_test
    }

    it "skips weekly build when already completed this week"  && {
      setup_test 05
      mock_date "2024-08-18" "03" "7"  # Sunday 3 AM
      
      # Pre-populate state with this week
      mkdir -p .fraggle-state
      cat > .fraggle-state/fraggle-state.ncl << 'EOF'
let state_types = import "./fraggle-state.ncl" in
{
  last_weekly = "2024-W33",  
  build_history = [],
} | state_types.FraggleState
EOF
      
      result=$(run_fraggle)
      
      expect "$result" to_be "[]"
      teardown_test
    }
  }

  context "matrix entry validation"  && {
    
    it "produces valid matrix entries with correct structure"  && {
      setup_test 06
      mock_date "2024-08-15" "02" "4"
      
      result=$(run_fraggle)
      
      # Validate JSON structure
      expect "$(to_be_valid_json "$result"; echo $?)" to_be "0"
      
      # Check each entry has required fields
      pipeline_count=$(echo "$result" | jq '[.[] | select(has("pipeline") and has("trigger") and has("priority") and has("schedule"))] | length')
      total_count=$(echo "$result" | jq 'length')
      
      expect "$pipeline_count" to_be "$total_count"
      
      teardown_test
    }

    it "assigns correct priorities to different build types"  && {
      setup_test 07
      mock_date "2024-08-18" "02" "7"  # Sunday 2 AM - could trigger both nightly and weekly
      
      result=$(run_fraggle)
      
      # Check nightly builds have priority 8
      nightly_priorities=$(echo "$result" | jq '[.[] | select(.trigger == "nightly_build").priority] | unique')
      expect "$nightly_priorities" to_be "[8]"
      
      teardown_test
    }
  }

  context "state management"  && {
    
    it "initializes empty state when no state file exists"  && {
      setup_test
      mock_date "2024-08-15" "10" "4"  # Non-build time
      
      # Ensure no state file exists
      rm -rf .fraggle-state
      
      result=$(run_fraggle)
      
      expect ".fraggle-state" to_exist
      expect ".fraggle-state/fraggle-state.ncl" to_exist
      expect "$(cat .fraggle-state/fraggle-state.ncl)" to_match "empty_state"
      
      teardown_test
    }

    it "preserves build history when updating state"  && {
      setup_test
      mock_date "2024-08-15" "02" "4"
      
      # Pre-populate state with some history
      mkdir -p .fraggle-state
      cat > .fraggle-state/fraggle-state.ncl << 'EOF'
let state_types = import "./fraggle-state.ncl" in
{
  last_nightly = "2024-08-14",
  build_history = [
    {
      date = "2024-08-14",
      trigger = 'nightly_build,
      pipelines = ["keg/old-app/nightly"],
    }
  ],
} | state_types.FraggleState
EOF
      
      result=$(run_fraggle)
      
      # Check history is preserved and extended
      expect "$(cat .fraggle-state/fraggle-state.ncl)" to_match "2024-08-14"
      expect "$(cat .fraggle-state/fraggle-state.ncl)" to_match "2024-08-15"
      
      teardown_test
    }
  }

  context "error handling"  && {
    
    it "handles invalid harbour configuration gracefully"  && {
      setup_test
      mock_date "2024-08-15" "02" "4"
      
      # Pass invalid JSON
      result=$(echo '{"invalid": "config"}' | "$FRAGGLE_SCRIPT" 2>/dev/null)
      
      expect "$result" to_be "[]"
      teardown_test
    }

    it "recovers from corrupted state file"  && {
      setup_test
      mock_date "2024-08-15" "02" "4"
      
      # Create corrupted state file
      mkdir -p .fraggle-state
      echo "invalid nickel syntax {" > .fraggle-state/fraggle-state.ncl
      
      run_fraggle >/dev/null 2>&1
      exit_code=$?
      
      # Should handle gracefully (exit 0 or continue processing)
      expect "$exit_code" to_be "0"
      teardown_test
    }
  }

  context "edge cases"  && {
    
    it "handles simultaneous nightly and weekly build time"  && {
      setup_test
      # Note: This is a theoretical edge case - Sunday 2 AM could be both nightly and weekly trigger time
      mock_date "2024-08-18" "02" "7"  # Sunday 2 AM 
      
      run_fraggle >/dev/null 2>&1
      exit_code=$?
      result=$(run_fraggle)
      
      # Should handle this edge case without error
      expect "$exit_code" to_be "0"
      expect "$(to_be_valid_json "$result"; echo $?)" to_be "0"
      
      teardown_test
    }

    it "processes pipelines with missing optional fields"  && {
      setup_test
      mock_date "2024-08-15" "02" "4"
      
      # Create minimal config with some pipelines missing optional fields
      minimal_config='{"pipelines": [{"pipeline": "keg/minimal/nightly"}]}'
      
      echo "$minimal_config" | "$FRAGGLE_SCRIPT" >/dev/null 2>&1
      exit_code=$?
      
      expect "$exit_code" to_be "0"
      teardown_test
    }
  }
}