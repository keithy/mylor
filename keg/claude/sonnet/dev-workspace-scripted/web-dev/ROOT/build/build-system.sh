#!/bin/bash
set -euo pipefail

echo "=== System Setup ==="

# Load build environment if it exists
[ -f "/${BUILD_ENV}" ] && source "/${BUILD_ENV}" || true

# Install minimal system requirements
echo "Installing system packages..."
apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Update CA certificates (overlay may have added custom certs)
update-ca-certificates 2>/dev/null || true

echo "=== System setup completed ==="