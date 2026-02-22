#!/bin/bash
# Quick Status Check for Termux Setup
# Run this to see what's been completed

export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "🔍 Checking Termux Setup Status on Honor 10"
echo "=========================================="
echo ""

# Check if device is connected
if ! adb devices | grep -q "device$"; then
    echo "❌ Device not connected"
    exit 1
fi

echo "✅ Device connected: $(adb shell getprop ro.product.model | tr -d '\r')"
echo ""

# Function to check if file exists in Termux
check_file() {
    local file="$1"
    local desc="$2"

    # Try to check via intent
    adb shell "am broadcast --user 0 -a com.termux.RUN_COMMAND -n com.termux/com.termux.app.RunCommandService --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,test -e $file && echo EXISTS || echo MISSING' --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home'" 2>/dev/null | grep -q "EXISTS"

    if [ $? -eq 0 ]; then
        echo "✅ $desc"
        return 0
    else
        echo "⏳ $desc - waiting..."
        return 1
    fi
}

echo "Checking installations:"
echo ""

# Check Bun
check_file "~/.bun/bin/bun" "Bun runtime installed"

# Check Git
adb shell "am broadcast --user 0 -a com.termux.RUN_COMMAND -n com.termux/com.termux.app.RunCommandService --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/which' --esa com.termux.RUN_COMMAND_ARGUMENTS 'git' --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home'" 2>/dev/null | grep -q "git" && echo "✅ Git installed" || echo "⏳ Git - waiting..."

# Check DroidClaw
check_file "~/droidclaw/package.json" "DroidClaw repository cloned"

# Check .env
check_file "~/droidclaw/.env" ".env configuration file"

# Check dependencies
check_file "~/droidclaw/node_modules" "DroidClaw dependencies installed"

# Check listener
check_file "~/telegram-listener.sh" "Telegram listener script"

# Check screen
adb shell "am broadcast --user 0 -a com.termux.RUN_COMMAND -n com.termux/com.termux.app.RunCommandService --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/which' --esa com.termux.RUN_COMMAND_ARGUMENTS 'screen' --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home'" 2>/dev/null | grep -q "screen" && echo "✅ Screen installed" || echo "⏳ Screen - waiting..."

echo ""
echo "=========================================="
echo ""
echo "To verify manually on Honor 10, open Termux and run:"
echo "  ~/.bun/bin/bun --version"
echo "  ls ~/droidclaw"
echo "  cat ~/droidclaw/.env | head -5"
echo ""
