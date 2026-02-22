#!/bin/bash
# Automated Termux Setup via ADB
# This script automates as much as possible from the PC side

set -e

cd "$(dirname "$0")"

# Set PATH for ADB
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "🚀 Automated Termux Setup for DroidClaw"
echo "========================================"
echo ""

# Check device connection
echo "📱 Checking device connection..."
if ! adb devices | grep -q "device$"; then
    echo "❌ No device connected. Please connect Honor 10 via USB."
    exit 1
fi
echo "✅ Device connected: $(adb shell getprop ro.product.model)"
echo ""

# Step 1: Grant storage permission to Termux (requires user interaction)
echo "Step 1: Granting storage permissions..."
echo "⚠️  Please tap 'ALLOW' on your Honor 10 when prompted for storage permission"
adb shell am start -n com.termux/.app.TermuxActivity
sleep 3
adb shell input text "termux-setup-storage" && adb shell input keyevent 66
sleep 2
echo ""

# Step 2: Run initial Termux commands via ADB
echo "Step 2: Running Termux setup commands..."
echo "   📦 Updating packages..."
adb shell "am broadcast -a com.termux.app.RUN_COMMAND -e com.termux.RUN_COMMAND_PATH /data/data/com.termux/files/usr/bin/bash -e com.termux.RUN_COMMAND_ARGUMENTS '-c,pkg update -y && pkg upgrade -y'" 2>/dev/null || true
sleep 5

echo "   📦 Installing git, curl, nodejs, jq..."
adb shell "am broadcast -a com.termux.app.RUN_COMMAND -e com.termux.RUN_COMMAND_PATH /data/data/com.termux/files/usr/bin/bash -e com.termux.RUN_COMMAND_ARGUMENTS '-c,pkg install -y git curl wget nodejs jq'" 2>/dev/null || true
sleep 30

echo "   📦 Installing Bun..."
adb shell "am broadcast -a com.termux.app.RUN_COMMAND -e com.termux.RUN_COMMAND_PATH /data/data/com.termux/files/usr/bin/bash -e com.termux.RUN_COMMAND_ARGUMENTS '-c,curl -fsSL https://bun.sh/install | bash'" 2>/dev/null || true
sleep 15

echo ""
echo "⏱️  Waiting for installations to complete (this may take 3-5 minutes)..."
echo "    You can check progress on the Honor 10 screen in Termux"
echo ""
sleep 60

# Step 3: Clone DroidClaw
echo "Step 3: Cloning DroidClaw repository..."
adb shell "am broadcast -a com.termux.app.RUN_COMMAND -e com.termux.RUN_COMMAND_PATH /data/data/com.termux/files/usr/bin/bash -e com.termux.RUN_COMMAND_ARGUMENTS '-c,cd ~ && git clone https://github.com/unitedbyai/droidclaw.git'" 2>/dev/null || true
sleep 10
echo ""

# Step 4: Copy .env template to DroidClaw directory
echo "Step 4: Configuring environment file..."
adb shell "cp /sdcard/droidclaw-env /data/data/com.termux/files/home/droidclaw/.env" 2>/dev/null || true
echo ""

# Step 5: Install DroidClaw dependencies
echo "Step 5: Installing DroidClaw dependencies (932 packages)..."
echo "⏱️  This takes 2-3 minutes..."
adb shell "am broadcast -a com.termux.app.RUN_COMMAND -e com.termux.RUN_COMMAND_PATH /data/data/com.termux/files/usr/bin/bash -e com.termux.RUN_COMMAND_ARGUMENTS '-c,cd ~/droidclaw && ~/.bun/bin/bun install'" 2>/dev/null || true
sleep 120
echo ""

# Step 6: Create telegram listener script
echo "Step 6: Creating Telegram listener service..."
cat > /tmp/telegram-listener.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/droidclaw

source .env
LAST_UPDATE_ID=0

echo "🤖 Agent Claus listening for Telegram messages..."

while true; do
  UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=$((LAST_UPDATE_ID + 1))")
  MESSAGE_COUNT=$(echo "$UPDATES" | jq '.result | length')

  if [ "$MESSAGE_COUNT" -gt 0 ]; then
    for i in $(seq 0 $((MESSAGE_COUNT - 1))); do
      UPDATE_ID=$(echo "$UPDATES" | jq -r ".result[$i].update_id")
      MESSAGE_TEXT=$(echo "$UPDATES" | jq -r ".result[$i].message.text // empty")

      if [ ! -z "$MESSAGE_TEXT" ] && [ "$MESSAGE_TEXT" != "null" ]; then
        echo "📩 Received: $MESSAGE_TEXT"

        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
          -d "chat_id=${TELEGRAM_CHAT_ID}" \
          -d "text=🤖 Processing: $MESSAGE_TEXT..."

        RESULT=$(echo "$MESSAGE_TEXT" | timeout 300 ~/.bun/bin/bun run src/kernel.ts 2>&1 | tail -20)

        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
          -d "chat_id=${TELEGRAM_CHAT_ID}" \
          -d "text=✅ Completed: $MESSAGE_TEXT"
      fi

      LAST_UPDATE_ID=$UPDATE_ID
    done
  fi

  sleep 5
done
EOF

adb push /tmp/telegram-listener.sh /sdcard/telegram-listener.sh
adb shell "cp /sdcard/telegram-listener.sh /data/data/com.termux/files/home/telegram-listener.sh && chmod +x /data/data/com.termux/files/home/telegram-listener.sh" 2>/dev/null || true
echo ""

# Summary
echo "=========================================="
echo "✅ Automated Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps (MANUAL on Honor 10):"
echo ""
echo "1. Open Termux on Honor 10"
echo "2. Test DroidClaw works:"
echo "   cd ~/droidclaw"
echo "   ~/.bun/bin/bun run src/kernel.ts"
echo "   Type: 'open settings'"
echo ""
echo "3. Start Telegram listener:"
echo "   ~/telegram-listener.sh"
echo ""
echo "4. Test from another device:"
echo "   Message @AgentClausCN_bot: 'open settings'"
echo ""
echo "5. Enable auto-start (optional):"
echo "   - Install Termux:Boot APK"
echo "   - Grant accessibility permissions"
echo "   - Disable battery optimization for Termux"
echo ""
echo "📄 Full guide: /sdcard/TERMUX-SETUP-GUIDE.md"
echo ""
