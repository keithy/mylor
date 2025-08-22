#!/usr/bin/env bash
# run_tests.sh - keithy/bash-spec-2 test runner for fraggle-cron.ncl.sh

set -euo pipefail

# Test utilities
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$here/../../../../bash-spec-2/bash-spec.sh"


# Check prerequisites
if ! command -v nickel >/dev/null 2>&1; then
    echo "ERROR: nickel not found - run 'mise install'"
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "ERROR: jq not found"  
    exit 1
fi

echo "Running keithy/bash-spec-2 tests for fraggle-cron.ncl.sh..."
echo "========================================================="

# Run the spec file with submodule bash-spec
cd "$here"
bash fraggle_cron.spec.sh