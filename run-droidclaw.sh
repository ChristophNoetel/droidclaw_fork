#!/bin/bash
# DroidClaw Launch Script with proper ADB path

# Set PATH to include ADB
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

# Change to DroidClaw directory
cd /c/Users/I526653/Documents/GitHub/personal_cnoetel/DroidClaw

# Run DroidClaw
/c/Users/I526653/.bun/bin/bun.exe run src/kernel.ts "$@"
