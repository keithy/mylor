#!/bin/sh
echo "=== Web Development Workspace Build Successful ==="
echo "User: ${USER:-dev} (UID: ${UID:-1000})"
echo "Tools installed:"
su - ${USER:-dev} -c 'export PATH="$HOME/.local/share/mise/bin:$PATH" && mise list --installed' 2>/dev/null || echo "mise not available yet"
echo "=== Build completed successfully ==="