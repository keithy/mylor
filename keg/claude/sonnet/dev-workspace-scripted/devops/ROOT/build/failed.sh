#!/bin/sh
echo "=== Developer Workspace Build Failed ==="
echo "User: ${USER:-dev} (UID: ${UID:-1000})"  
echo "Build script: /${BUILD_SCRIPT}"
echo "On fail action: ${ON_FAIL:-exit}"
echo "Check build logs above for error details"
echo "=== Build failed ==="