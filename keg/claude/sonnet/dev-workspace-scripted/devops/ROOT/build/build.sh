#!/bin/bash
set -euo pipefail

echo "=== Building DevOps Workspace ==="
echo "User: ${USER:-dev} (UID: ${UID:-1000})"

# System setup
/build/build-system.sh

# User setup  
/build/build-user.sh

echo "=== DevOps workspace build completed ==="