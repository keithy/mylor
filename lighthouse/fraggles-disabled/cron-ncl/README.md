# Testing fraggle-cron.ncl.sh with keithy/bash-spec-2

This directory contains keithy/bash-spec-2 tests for the `fraggle-cron.ncl.sh` Nickel-based cron scheduler.

## Files

- `fraggle_cron_spec.sh` - Main bash-spec test file with describe/it blocks
- `test_helper.sh` - Custom matchers and utility functions  
- `run_tests.sh` - Test runner script with prerequisite checks
- `test-fixtures/sample-harbour-config.ncl` - Sample test configuration
- `fraggle-state.ncl` - State type definitions (used by both script and tests)

## Test Coverage

### Scheduling Scenarios
- ✅ **Nightly builds at 2 AM UTC** - Matrix generation and state updates
- ✅ **Weekly builds at 3 AM Sunday** - Weekly scheduling logic
- ✅ **Skip logic** - Prevents duplicate builds on same day/week
- ✅ **Non-build hours** - No action outside scheduled times

### Matrix Validation  
- ✅ **JSON structure** - Valid JSON output with required fields
- ✅ **Priority assignment** - Correct priorities (nightly=8, weekly=5)
- ✅ **Trigger types** - Proper nightly_build/weekly_build categorization
- ✅ **Pipeline processing** - All configured pipelines included

### State Management
- ✅ **Initialization** - Creates empty state when missing
- ✅ **Persistence** - Updates last_nightly/last_weekly dates
- ✅ **History tracking** - Preserves and extends build_history
- ✅ **Nickel validation** - All state conforms to FraggleState contract

### Error Handling
- ✅ **Invalid configurations** - Graceful handling of malformed input
- ✅ **Corrupted state** - Recovery from invalid state files
- ✅ **Missing fields** - Processes pipelines with optional fields missing
- ✅ **Edge cases** - Simultaneous scheduling scenarios

## Running Tests

### Prerequisites
```bash
# Initialize bash-spec-2 submodule (if not already done)
git submodule update --init --recursive

# Install project dependencies
mise install  # installs nickel, jq, etc.
```

### Execute Tests
```bash
# Run all tests
cd mylor/lighthouse/fraggles/cron
./run_tests.sh

# Run specific test file directly
bash fraggle_cron_spec.sh
```

### Test Output Example
```
fraggle-cron.ncl.sh scheduler
  nightly build scheduling at 2 AM UTC
    ✓ generates nightly build matrix when no previous build today
    ✓ skips nightly build when already completed today  
    ✓ does nothing outside nightly build hours
    
  weekly build scheduling at 3 AM Sunday
    ✓ generates weekly build matrix when no previous build this week
    ✓ skips weekly build when already completed this week
    
  matrix entry validation
    ✓ produces valid matrix entries with correct structure
    ✓ assigns correct priorities to different build types
    
  state management
    ✓ initializes empty state when no state file exists
    ✓ preserves build history when updating state
    
  error handling  
    ✓ handles invalid harbour configuration gracefully
    ✓ recovers from corrupted state file
    
  edge cases
    ✓ handles simultaneous nightly and weekly build time
    ✓ processes pipelines with missing optional fields

14 tests, 0 failures
```

## keithy/bash-spec-2 Features Used

### Describe/It Structure with Curly Braces
```bash
describe "feature being tested" && {
  context "specific context" && {
    it "specific behavior" && {
      # test code
    }
  }
}
```

### Available Matchers
- `to_be` - Exact equality matching
- `to_match` - Regex pattern matching  
- `to_exist` - File/directory existence
- `to_contain` - Array element equality
- Custom helper: `to_be_valid_json` - JSON validation

### Setup/Teardown
- `setup_test()` - Creates isolated test environment per test
- `teardown_test()` - Cleans up temp directories and state

### Test Isolation
Each test runs in its own temporary directory with:
- Fresh state files
- Mock date commands for time control  
- Sample configuration data
- Clean PATH environment

## Adding New Tests

1. **Add new `it` block** to appropriate `describe` section:
```bash
it "handles new edge case"
    setup
    # test logic here
    expect "$result" to_equal "expected"
    teardown
end
```

2. **Add helper functions** to `test_helper.sh` if needed

3. **Update this README** with new test coverage

## Debugging

- Use `bash -x fraggle_cron_spec.sh` for detailed execution trace
- Check temp directories: tests create `/tmp/tmp.*` directories during execution
- Validate Nickel syntax: `nickel eval --format json < file.ncl`
- Test individual functions: source test files and call functions directly

## Why keithy/bash-spec-2?

- **Native bash** - No external dependencies beyond bash-spec.sh
- **Clean syntax** - Clear describe/context/it structure with curly braces
- **Lightweight** - Simple single-file framework  
- **Shell-native** - Perfect for testing shell scripts and command-line tools
- **Flexible** - Multiple syntax options (command substitution or curly braces)