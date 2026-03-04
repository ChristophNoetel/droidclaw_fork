#!/bin/bash
# Automated Termux Configuration via ADB
# This script configures Termux on the Honor 10 through ADB commands

set -e

cd "$(dirname "$0")"
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "🤖 Automated Termux Configuration via ADB"
echo "=========================================="
echo ""

# Check device connection
echo "📱 Checking device connection..."
if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected. Please connect Honor 10 via USB."
    exit 1
fi

DEVICE_MODEL=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
echo "✅ Device connected: $DEVICE_MODEL"
echo ""

# Function to run command in Termux with security validation
run_in_termux() {
    local cmd="$1"

    # Validate command doesn't contain suspicious patterns
    if echo "$cmd" | grep -qE '[;&|`$(){}<>]'; then
        echo "   ERROR: Command contains forbidden characters"
        return 1
    fi

    # Use printf %q for proper shell escaping
    local escaped_cmd=$(printf '%q' "$cmd")

    echo "   Running: $cmd"

    # Try methods in order of preference
    # Method 1: su (if device is rooted)
    adb shell "su -c 'cd /data/data/com.termux/files/home && ${escaped_cmd}'" 2>/dev/null && return 0

    # Method 2: am broadcast with properly escaped command
    adb shell "am broadcast \
        -a com.termux.app.RUN_COMMAND \
        -n com.termux/com.termux.app.RunCommandService \
        --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' \
        --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,${escaped_cmd}' \
        --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home'" 2>/dev/null && return 0

    # Method 3: run-as (fallback)
    adb shell "run-as com.termux /data/data/com.termux/files/usr/bin/bash -c '${escaped_cmd}'" 2>/dev/null && return 0

    echo "   ERROR: All execution methods failed"
    return 1
}

# Step 1: Launch Termux
echo "Step 1: Launching Termux..."
adb shell am start -n com.termux/.app.TermuxActivity >/dev/null 2>&1
sleep 3
echo "✅ Termux launched"
echo ""

# Step 2: Grant storage permission
echo "Step 2: Requesting storage permission..."
echo "   ⚠️  Please tap 'ALLOW' on your Honor 10 if prompted"
adb shell input text "termux-setup-storage" && adb shell input keyevent 66
sleep 3
echo ""

# Step 3: Update packages
echo "Step 3: Updating Termux packages..."
echo "   This may take 2-3 minutes..."
adb shell input text "pkg%supdate%s-y%s%26%26%spkg%supgrade%s-y" && adb shell input keyevent 66
sleep 120
echo "✅ Packages updated"
echo ""

# Step 4: Install essential tools
echo "Step 4: Installing git, curl, wget, nodejs, jq..."
echo "   This may take 3-4 minutes..."
adb shell input text "pkg%sinstall%s-y%sgit%scurl%swget%snodejs%sjq" && adb shell input keyevent 66
sleep 180
echo "✅ Essential tools installed"
echo ""

# Step 5: Install Bun
echo "Step 5: Installing Bun runtime..."
adb shell input text "curl%s-fsSL%shttps://bun.sh/install%s%7C%sbash" && adb shell input keyevent 66
sleep 30
echo "✅ Bun installed"
echo ""

# Step 6: Configure Bun PATH
echo "Step 6: Configuring Bun PATH..."
adb shell input text "export%sBUN_INSTALL=%s%24HOME/.bun%s%26%26%sexport%sPATH=%s%24BUN_INSTALL/bin:%24PATH" && adb shell input keyevent 66
sleep 2
adb shell input text "echo%s'export%sBUN_INSTALL=%22%24HOME/.bun%22'%s%3E%3E%s~/.bashrc" && adb shell input keyevent 66
sleep 2
adb shell input text "echo%s'export%sPATH=%22%24BUN_INSTALL/bin:%24PATH%22'%s%3E%3E%s~/.bashrc" && adb shell input keyevent 66
sleep 2
echo "✅ Bun PATH configured"
echo ""

# Step 7: Clone DroidClaw
echo "Step 7: Cloning DroidClaw repository..."
adb shell input text "cd%s~%s%26%26%sgit%sclone%shttps://github.com/unitedbyai/droidclaw.git" && adb shell input keyevent 66
sleep 15
echo "✅ DroidClaw cloned"
echo ""

# Step 8: Install dependencies
echo "Step 8: Installing DroidClaw dependencies (932 packages)..."
echo "   This may take 2-3 minutes..."
adb shell input text "cd%s~/droidclaw%s%26%26%s~/.bun/bin/bun%sinstall" && adb shell input keyevent 66
sleep 120
echo "✅ Dependencies installed"
echo ""

# Step 9: Configure .env
echo "Step 9: Copying .env configuration..."
adb shell input text "cp%s/sdcard/droidclaw-env%s~/droidclaw/.env" && adb shell input keyevent 66
sleep 2
echo "✅ .env configured"
echo ""

# Step 10: Create telegram listener
echo "Step 10: Setting up Telegram listener..."
adb shell input text "cp%s/sdcard/telegram-listener.sh%s~/telegram-listener.sh%s%26%26%schmod%s+x%s~/telegram-listener.sh" && adb shell input keyevent 66
sleep 2
echo "✅ Telegram listener ready"
echo ""

# Step 11: Install screen
echo "Step 11: Installing screen for persistent sessions..."
adb shell input text "pkg%sinstall%s-y%sscreen" && adb shell input keyevent 66
sleep 30
echo "✅ Screen installed"
echo ""

echo "=========================================="
echo "✅ Automated Setup Complete!"
echo "=========================================="
echo ""
echo "Verification steps:"
echo "1. Check Termux on Honor 10 screen"
echo "2. Verify installations completed successfully"
echo ""
echo "Next: Test DroidClaw"
echo "   Type in Termux: cd ~/droidclaw && ~/.bun/bin/bun run src/kernel.ts"
echo "   Goal: 'open settings'"
echo ""
