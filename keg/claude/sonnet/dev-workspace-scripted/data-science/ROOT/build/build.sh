#!/bin/bash
set -euo pipefail

echo "=== Building Data Science Workspace ==="
echo "User: ${USER:-dev} (UID: ${UID:-1000})"

# System setup
/build/build-system.sh

# User setup  
/build/build-user.sh

echo "=== Data science workspace build completed ==="