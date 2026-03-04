#!/bin/bash
# Simple test for Munich weather workflow

cd /c/Users/I526653/Documents/GitHub/personal_cnoetel/DroidClaw

# Set environment variables directly
export TELEGRAM_BOT_TOKEN="7935511874:AAHb1WHPY9rOkPmYtGXtk8H0_dbM3frEirw"
export TELEGRAM_CHAT_ID="1476586973"
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "Testing Munich weather workflow..."
echo "Device status:"
adb devices

echo ""
echo "Starting workflow (this may take 1-2 minutes)..."

# Run the workflow with a simple goal
echo "search for weather Munich and tell me the temperature" | timeout 120 /c/Users/I526653/.bun/bin/bun.exe run src/kernel.ts 2>&1 | tail -20
