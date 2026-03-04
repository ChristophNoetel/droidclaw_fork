#!/bin/bash
# Simple test for Munich weather workflow

cd "$(dirname "$0")/.."

# Load environment variables from .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "Testing Munich weather workflow..."
echo "Device status:"
adb devices

echo ""
echo "Starting workflow (this may take 1-2 minutes)..."

# Run the workflow with a simple goal
echo "search for weather Munich and tell me the temperature" | timeout 120 /c/Users/I526653/.bun/bin/bun.exe run src/kernel.ts 2>&1 | tail -20
