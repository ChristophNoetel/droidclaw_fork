# Quick Start: Termux Autonomous Agent

## ✅ Current Status
- ✅ Termux installed on Honor 10
- ✅ Setup scripts ready on device storage
- ✅ Configuration files prepared

## 🚀 Next: Complete Setup on Honor 10

### On Your Honor 10 Tablet:

#### 1. Open Termux
- Tap the Termux app icon
- Wait for the `$` prompt to appear

#### 2. Grant Storage Permission
Type this command and press Enter:
```bash
termux-setup-storage
```
- Tap **"Allow"** when prompted

#### 3. Run Automated Setup
Copy and paste these commands (tap and hold in Termux to paste):

```bash
# Update packages
pkg update -y && pkg upgrade -y

# Install essential tools (takes 2-3 minutes)
pkg install -y git curl wget nodejs jq

# Install Bun runtime
curl -fsSL https://bun.sh/install | bash

# Add Bun to PATH
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

# Verify installations
echo "Checking versions..."
git --version
node --version
bun --version
```

#### 4. Clone DroidClaw
```bash
cd ~
git clone https://github.com/unitedbyai/droidclaw.git
cd droidclaw
```

#### 5. Install Dependencies (takes 2-3 minutes)
```bash
bun install
```

#### 6. Configure Environment
```bash
# Copy pre-configured .env from storage
cp /sdcard/droidclaw-env .env

# Verify it worked
cat .env | head -5
```

#### 7. Test DroidClaw
```bash
bun run src/kernel.ts
```

When prompted, type:
```
open settings
```

If Settings opens → **SUCCESS!** Press `Ctrl+C` to stop.

#### 8. Set Up Telegram Listener
```bash
# Copy listener script
cp /sdcard/telegram-listener.sh ~/telegram-listener.sh
chmod +x ~/telegram-listener.sh

# Install screen for persistent sessions
pkg install -y screen

# Start listener in screen session
screen -S agent
~/telegram-listener.sh
```

**To detach and leave it running:**
- Press `Ctrl+A`, then press `D`

**To reattach later:**
```bash
screen -r agent
```

#### 9. Test from Another Device
From your phone or computer, message:
**@AgentClausCN_bot**

Send:
```
open settings
```

Your Honor 10 should automatically open Settings!

---

## 🔋 Keep It Running

### Make it survive reboots:

1. **Disable Battery Optimization**
   - Settings → Battery → Termux
   - Disable battery optimization
   - Allow background activity

2. **Install Termux:Boot**
   - Download from: https://github.com/termux/termux-boot/releases
   - Install `termux-boot-*.apk`
   - Create startup script:
   ```bash
   mkdir -p ~/.termux/boot
   cat > ~/.termux/boot/start-agent.sh <<'EOF'
   #!/data/data/com.termux/files/usr/bin/bash
   termux-wake-lock
   screen -dmS agent ~/telegram-listener.sh
   EOF
   chmod +x ~/.termux/boot/start-agent.sh
   ```

3. **Grant Accessibility Permissions**
   - Settings → Accessibility
   - Find Termux
   - Enable accessibility service
   - Grant all permissions

---

## ✅ Verification

After setup, you should have:

- ✅ Termux opens and shows prompt
- ✅ `bun --version` shows v1.x.x
- ✅ `~/droidclaw` directory exists
- ✅ `~/droidclaw/.env` file configured
- ✅ DroidClaw can control apps (tested with Settings)
- ✅ Telegram listener responds to messages
- ✅ Works unplugged from PC

---

## 🆘 Troubleshooting

**"command not found: bun"**
```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

**"permission denied"**
```bash
termux-setup-storage
# Then tap "Allow"
```

**"cannot clone repository"**
```bash
pkg install git -y
```

**Listener stops responding**
```bash
# Check if still running
screen -ls

# Restart
screen -r agent
# Then press Ctrl+C and restart ~/telegram-listener.sh
```

**DroidClaw cannot control apps**
- Grant accessibility permissions in Android Settings
- Enable "Draw over other apps" for Termux

---

## 📱 Daily Usage

**Start listener:**
```bash
screen -S agent
~/telegram-listener.sh
```
Then `Ctrl+A`, `D` to detach

**Check if running:**
```bash
screen -ls
```

**Stop listener:**
```bash
screen -r agent
# Then Ctrl+C
```

**View logs:**
```bash
cd ~/droidclaw/logs
ls -lt
cat latest-session.json
```

**Add scheduled tasks:**
```bash
pkg install cronie termux-services
sv-enable crond
crontab -e
```

Add for 9am weather:
```
0 9 * * * cd ~/droidclaw && ~/.bun/bin/bun run src/kernel.ts --workflow examples/workflows/custom/daily-munich-weather.json
```

---

## 🎉 You're Done!

Your Honor 10 is now a **fully autonomous AI agent**!

- Message @AgentClausCN_bot from anywhere
- Agent executes tasks on the device
- No PC connection needed
- Runs on battery
- $0 cost

**Full documentation:** `/sdcard/TERMUX-SETUP-GUIDE.md`
