#!/bin/bash
set -euo pipefail

echo "=== Building Base Developer Workspace ==="
echo "User: ${USER:-dev} (UID: ${UID:-1000})"
echo "Build Config: ${BUILD_CONFIG:-config-default.sh}"
echo "Build Env: ${BUILD_ENV:-default.env}"

# System setup (as root)
/build/build-system.sh

# User setup (run as the user)
su - ${USER:-dev} -c '/build/build-user.sh'

echo "=== Base workspace build completed ==="