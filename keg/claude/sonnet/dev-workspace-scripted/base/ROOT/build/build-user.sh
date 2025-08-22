#!/bin/bash
set -euo pipefail

echo "=== User Setup (running as $(whoami)) ==="

# Install mise 
echo "Installing mise..."
curl -fsSL https://mise.jdx.dev/install.sh | sh -s -- -y

# Export PATH for mise
export PATH="$HOME/.local/share/mise/bin:$PATH"

# Install tools via mise
echo "Installing development tools via mise..."
mise install

# Set up shell activation
echo "Configuring shell environment..."
echo 'eval "$(mise activate bash)"' >> ~/.bashrc

# Create workspace directory
mkdir -p ~/workspace

# Fix permissions on any overlaid files in home directory (already owned by user)
chmod 700 ~/.ssh 2>/dev/null || true  
chmod 600 ~/.ssh/* 2>/dev/null || true

echo "=== User setup completed ==="