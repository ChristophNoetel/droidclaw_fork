# Termux Autonomous Setup Guide

## What You'll Achieve
Your Honor 10 will become a fully autonomous agent that:
- Runs DroidClaw independently (no PC needed)
- Responds to Telegram messages with LLM reasoning
- Executes scheduled tasks (like 9am weather)
- Operates 24/7 on battery/charger

---

## Step 1: Open Termux on Your Honor 10

1. On your Honor 10, find and tap the **Termux** app icon
2. You'll see a black terminal screen
3. Wait for the initial setup to complete (shows a `$` prompt)

---

## Step 2: Copy Setup Script from Storage

In Termux, type these commands one at a time:

```bash
# Copy the setup script from storage to Termux
cp /sdcard/termux-setup.sh ~/termux-setup.sh

# Make it executable
chmod +x ~/termux-setup.sh

# Run the setup script
~/termux-setup.sh
```

This script will:
- Update Termux packages
- Install git, curl, nodejs
- Install Bun runtime
- Set up environment

**⏱️ This takes 5-10 minutes** (downloads ~200MB of packages)

---

## Step 3: Grant Storage Permission

When prompted:
1. Termux will ask for storage permissions
2. Tap **"Allow"** to let Termux access device storage
3. This is needed to read/write files for DroidClaw

Alternative manual command:
```bash
termux-setup-storage
```

---

## Step 4: Clone DroidClaw Repository

```bash
cd ~
git clone https://github.com/unitedbyai/droidclaw.git
cd droidclaw
```

---

## Step 5: Install DroidClaw Dependencies

```bash
bun install
```

**⏱️ This takes 2-3 minutes** (installs 932 packages)

---

## Step 6: Configure Environment Variables

Create the `.env` file with your API keys:

```bash
nano .env
```

Paste this content (I'll provide the exact values via ADB):

```env
# LLM Configuration
LLM_PROVIDER=groq
GROQ_API_KEY=YOUR_GROQ_API_KEY_HERE
GROQ_MODEL=llama-3.3-70b-versatile

# Telegram Bot
TELEGRAM_BOT_TOKEN=7935511874:AAHb1WHPY9rOkPmYtGXtk8H0_dbM3frEirw
TELEGRAM_CHAT_ID=1476586973

# Agent Behavior
MAX_STEPS=30
STEP_DELAY=2
STUCK_THRESHOLD=3
VISION_MODE=fallback

# Performance
MAX_ELEMENTS=40
MAX_HISTORY_STEPS=10
```

**To save in nano:**
1. Press `Ctrl+X`
2. Press `Y` (to confirm save)
3. Press `Enter` (to confirm filename)

---

## Step 7: Test DroidClaw Works in Termux

```bash
# Test that DroidClaw can start
bun run src/kernel.ts
```

When prompted, type a simple goal:
```
open settings
```

If the Settings app opens on your Honor 10, **SUCCESS!** Press `Ctrl+C` to stop.

---

## Step 8: Set Up Telegram Listener Service

Create the listener script:

```bash
nano ~/telegram-listener.sh
```

Paste:
```bash
#!/data/data/com.termux/files/usr/bin/bash
cd ~/droidclaw

# Load environment
export GROQ_API_KEY="YOUR_GROQ_API_KEY_HERE"
export TELEGRAM_BOT_TOKEN="7935511874:AAHb1WHPY9rOkPmYtGXtk8H0_dbM3frEirw"
export TELEGRAM_CHAT_ID="1476586973"

LAST_UPDATE_ID=0

echo "🤖 Agent Claus listening for Telegram messages..."

while true; do
  # Get updates from Telegram
  UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=$((LAST_UPDATE_ID + 1))")

  # Check if there are new messages
  MESSAGE_COUNT=$(echo "$UPDATES" | jq '.result | length')

  if [ "$MESSAGE_COUNT" -gt 0 ]; then
    # Process each message
    for i in $(seq 0 $((MESSAGE_COUNT - 1))); do
      UPDATE_ID=$(echo "$UPDATES" | jq -r ".result[$i].update_id")
      MESSAGE_TEXT=$(echo "$UPDATES" | jq -r ".result[$i].message.text // empty")

      if [ ! -z "$MESSAGE_TEXT" ] && [ "$MESSAGE_TEXT" != "null" ]; then
        echo "📩 Received: $MESSAGE_TEXT"

        # Send acknowledgment
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
          -d "chat_id=${TELEGRAM_CHAT_ID}" \
          -d "text=Processing: $MESSAGE_TEXT..."

        # Execute DroidClaw with the message as goal
        RESULT=$(echo "$MESSAGE_TEXT" | timeout 300 bun run src/kernel.ts 2>&1 | tail -20)

        # Send result back
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
          -d "chat_id=${TELEGRAM_CHAT_ID}" \
          -d "text=✅ Completed: $MESSAGE_TEXT"
      fi

      LAST_UPDATE_ID=$UPDATE_ID
    done
  fi

  sleep 5
done
```

Make it executable:
```bash
chmod +x ~/telegram-listener.sh
```

---

## Step 9: Install Termux:Boot (For Auto-Start)

1. Download Termux:Boot from GitHub:
   - https://github.com/termux/termux-boot/releases
   - Install `termux-boot-*.apk`

2. Create boot script:
```bash
mkdir -p ~/.termux/boot
nano ~/.termux/boot/start-agent.sh
```

Paste:
```bash
#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
~/telegram-listener.sh &
```

Make executable:
```bash
chmod +x ~/.termux/boot/start-agent.sh
```

---

## Step 10: Configure Accessibility Services

For DroidClaw to control UI elements:

1. Go to **Settings** → **Accessibility**
2. Find **Termux** (or **Termux:API** if installed)
3. Enable accessibility services
4. Grant all permissions

---

## Step 11: Test Autonomous Operation

### Test 1: Telegram Trigger
1. Unplug Honor 10 from PC
2. In Termux, run: `~/telegram-listener.sh`
3. From another device, message **@AgentClausCN_bot**:
   ```
   open settings
   ```
4. Watch your Honor 10 automatically open Settings
5. You should receive a "✅ Completed" message back

### Test 2: Scheduled Task
Create a scheduled task using Termux's cron:

```bash
# Install cron support
pkg install cronie termux-services

# Start cron daemon
sv-enable crond

# Edit crontab
crontab -e
```

Add this line for 9am weather:
```
0 9 * * * cd ~/droidclaw && bun run src/kernel.ts --workflow examples/workflows/custom/daily-munich-weather.json
```

Save and exit.

---

## Keeping It Running

### Option 1: Screen Session (Recommended)
```bash
# Install screen
pkg install screen

# Start a persistent session
screen -S agent

# Run listener
~/telegram-listener.sh

# Detach: Press Ctrl+A, then D
# Reattach later: screen -r agent
```

### Option 2: Termux:Boot (Auto-start on device boot)
Already configured in Step 9. Agent starts automatically when device boots.

### Option 3: Termux:Widget (Manual trigger)
1. Install Termux:Widget from GitHub
2. Create shortcut scripts in `~/.shortcuts/`
3. Add widget to home screen for one-tap start

---

## Battery Optimization

To prevent Android from killing Termux:

1. **Settings** → **Battery**
2. Find **Termux** app
3. Disable battery optimization
4. Allow background activity

---

## Troubleshooting

### Termux closes in background
- Disable battery optimization for Termux
- Use `termux-wake-lock` to prevent sleep
- Install Termux:Boot for auto-restart

### Cannot control UI
- Grant accessibility permissions
- Enable "Draw over other apps" permission
- Check that ADB wireless is enabled

### Groq API rate limit
- Free tier: 6,000 requests/day
- Switch to `llama-3.1-8b-instant` (faster, higher limits)
- Or install Ollama: `pkg install ollama`

### Telegram listener stops
- Run in `screen` session (persistent)
- Add auto-restart on crash:
  ```bash
  while true; do
    ~/telegram-listener.sh
    sleep 10
  done
  ```

---

## Verification Checklist

- ✅ Termux installed and opens
- ✅ Bun runtime installed (`bun --version`)
- ✅ DroidClaw cloned to `~/droidclaw`
- ✅ Dependencies installed (932 packages)
- ✅ `.env` configured with API keys
- ✅ Test run: DroidClaw can open settings
- ✅ Telegram listener responds to messages
- ✅ Accessibility services enabled
- ✅ Battery optimization disabled
- ✅ Boot script configured (optional)
- ✅ Can operate unplugged from PC

---

## What You've Achieved

Your Honor 10 is now a **fully autonomous AI agent** that:
- 🤖 Runs independently on the device
- 💬 Responds to Telegram commands with LLM reasoning
- 📅 Executes scheduled tasks (9am weather)
- 🔋 Works on battery power
- 🌐 No PC connection required
- 💰 $0 operating cost (free Groq API)

**Total setup time:** 20-30 minutes
**Complexity:** Medium (mostly copy-paste commands)
**Cost:** $0

---

## Next Steps

1. **Create more workflows**: Add to `~/droidclaw/examples/workflows/custom/`
2. **Add more scheduled tasks**: Edit crontab for additional automations
3. **Install Termux:API**: For sensors, camera, SMS, notifications
4. **Set up Ollama**: For fully offline LLM reasoning
5. **Create shortcuts**: Use Termux:Widget for quick actions

---

## Files on Device

```
~/droidclaw/                    # Main DroidClaw installation
~/telegram-listener.sh          # Telegram polling service
~/.termux/boot/start-agent.sh   # Auto-start on boot
/sdcard/termux-setup.sh         # Initial setup script
```

---

## Quick Reference Commands

```bash
# Start listener manually
~/telegram-listener.sh

# Start in screen session
screen -S agent
~/telegram-listener.sh
# Ctrl+A, then D to detach

# Test DroidClaw interactively
cd ~/droidclaw
bun run src/kernel.ts

# Run workflow manually
bun run src/kernel.ts --workflow examples/workflows/custom/daily-munich-weather.json

# View logs
cd ~/droidclaw/logs
cat latest-session.json

# Stop all processes
pkill -f telegram-listener
pkill -f kernel.ts

# Restart Termux services
sv restart crond
```

---

**You now have a reasoning AI agent living on your phone!** 🎉
