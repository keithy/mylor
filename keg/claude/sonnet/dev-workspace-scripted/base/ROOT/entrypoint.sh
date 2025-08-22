#!/bin/sh
# Developer workspace entrypoint
# Activate mise and start bash

# Ensure mise is in path
export PATH="$HOME/.local/share/mise/bin:$PATH"

# Activate mise environment if available
if command -v mise >/dev/null 2>&1; then
    eval "$(mise env -s sh 2>/dev/null || true)"
fi

# Change to workspace directory
cd /home/${USER:-dev}/workspace 2>/dev/null || cd

# Start bash by default, or run provided command
if [ $# -eq 0 ]; then
    exec bash
else
    exec "$@"
fi