#!/bin/bash
# Complete Termux Setup Automation via ADB
# Sends all setup commands to Termux via intents

set -e
cd "$(dirname "$0")"
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "🤖 Automated Termux Setup via ADB Intents"
echo "=========================================="
echo ""

# Function to send command to Termux
send_termux_command() {
    local cmd="$1"
    local desc="$2"
    echo "📤 $desc"
    adb shell "am broadcast --user 0 -a com.termux.RUN_COMMAND -n com.termux/com.termux.app.RunCommandService --es com.termux.RUN_COMMAND_PATH '/data/data/com.termux/files/usr/bin/bash' --esa com.termux.RUN_COMMAND_ARGUMENTS '-c,$cmd' --es com.termux.RUN_COMMAND_WORKDIR '/data/data/com.termux/files/home'" > /dev/null 2>&1
}

# Check device
if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected"
    exit 1
fi

echo "✅ Device connected: $(adb shell getprop ro.product.model | tr -d '\r')"
echo ""

# Storage permission
echo "Step 1: Storage Permission"
send_termux_command "termux-setup-storage" "Requesting storage access..."
echo "   ⚠️  Tap ALLOW on Honor 10 if prompted"
sleep 3
echo ""

# Update packages
echo "Step 2: Update Packages (3 minutes)"
send_termux_command "yes | pkg update -y && yes | pkg upgrade -y" "Updating Termux packages..."
echo "   ⏱️  This runs in background, wait 3 minutes..."
sleep 180
echo ""

# Install tools
echo "Step 3: Install Tools (4 minutes)"
send_termux_command "yes | pkg install -y git curl wget nodejs jq" "Installing git, curl, nodejs, jq..."
echo "   ⏱️  This runs in background, wait 4 minutes..."
sleep 240
echo ""

# Install Bun
echo "Step 4: Install Bun (1 minute)"
send_termux_command "curl -fsSL https://bun.sh/install | bash" "Installing Bun runtime..."
sleep 60
echo ""

# Configure Bun PATH
echo "Step 5: Configure Bun"
send_termux_command "echo 'export BUN_INSTALL=\"\$HOME/.bun\"' >> ~/.bashrc && echo 'export PATH=\"\$BUN_INSTALL/bin:\$PATH\"' >> ~/.bashrc" "Adding Bun to PATH..."
sleep 2
echo ""

# Clone DroidClaw
echo "Step 6: Clone DroidClaw (30 seconds)"
send_termux_command "cd ~ && git clone https://github.com/unitedbyai/droidclaw.git" "Cloning DroidClaw repository..."
sleep 30
echo ""

# Install dependencies
echo "Step 7: Install Dependencies (3 minutes)"
send_termux_command "cd ~/droidclaw && ~/.bun/bin/bun install" "Installing 932 DroidClaw packages..."
echo "   ⏱️  This runs in background, wait 3 minutes..."
sleep 180
echo ""

# Copy .env
echo "Step 8: Configure .env"
send_termux_command "cp /sdcard/droidclaw-env ~/droidclaw/.env" "Copying environment configuration..."
sleep 2
echo ""

# Copy telegram listener
echo "Step 9: Setup Telegram Listener"
send_termux_command "cp /sdcard/telegram-listener.sh ~/telegram-listener.sh && chmod +x ~/telegram-listener.sh" "Installing Telegram listener..."
sleep 2
echo ""

# Install screen
echo "Step 10: Install Screen (30 seconds)"
send_termux_command "yes | pkg install -y screen" "Installing screen for persistent sessions..."
sleep 30
echo ""

# Verification
echo "Step 11: Verification"
send_termux_command "echo '=== SETUP COMPLETE ===' && echo 'Bun version:' && ~/.bun/bin/bun --version && echo 'Git version:' && git --version | head -1 && echo 'Node version:' && node --version && echo 'DroidClaw:' && ls -l ~/droidclaw | head -3" "Running verification..."
sleep 5
echo ""

echo "=========================================="
echo "✅ All Commands Sent!"
echo "=========================================="
echo ""
echo "Check your Honor 10 Termux screen to verify:"
echo "  • All installations completed"
echo "  • No error messages"
echo "  • Prompt shows: $"
echo ""
echo "Next: Test DroidClaw"
echo "On Honor 10, type in Termux:"
echo "  cd ~/droidclaw"
echo "  ~/.bun/bin/bun run src/kernel.ts"
echo "  Goal: open settings"
echo ""
