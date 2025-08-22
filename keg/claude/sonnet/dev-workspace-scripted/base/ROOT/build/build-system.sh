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

# Create user (must be done as root)
echo "Creating user: ${USER:-dev}"
useradd -m -u ${UID:-1000} ${USER:-dev}
usermod -aG sudo ${USER:-dev}
echo "${USER:-dev} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USER:-dev}

echo "=== System setup completed ==="