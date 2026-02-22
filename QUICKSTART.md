# DroidClaw Setup Guide - Quick Start

## What I've Prepared for You

I've set up the DroidClaw project structure with custom workflows ready to use. Here's what's done:

### ✅ Completed
1. **Repository**: Already cloned at `C:\Users\I526653\Documents\GitHub\droidclaw`
2. **Custom Workflows Folder**: Created at `examples/workflows/custom/`
3. **Daily Report Workflow**: `daily-report.json` - Collects emails, calendar, weather → sends via WhatsApp
4. **Monitor & Alert Workflow**: `monitor-and-alert.json` - Monitors an app → sends notifications
5. **Configuration File**: `.env` created with sensible defaults (you just need to add your API key)

### ⏳ What You Need to Do

#### Step 1: Install Bun (Required)
Open PowerShell as Administrator and run:
```powershell
powershell -c "irm bun.sh/install.ps1|iex"
```
After installation, **restart your terminal** to refresh PATH.

#### Step 2: Install ADB (Required)
Choose one method:

**Option A (Easiest):**
```powershell
winget install Google.PlatformTools
```

**Option B (Manual):**
1. Download from: https://developer.android.com/tools/releases/platform-tools
2. Extract to `C:\Android\platform-tools`
3. Add to PATH:
   - Win+X → System → Advanced → Environment Variables
   - Edit "Path" → Add `C:\Android\platform-tools`

**Option C (Chocolatey):**
```powershell
choco install adb
```

After installing, **restart your terminal**.

#### Step 3: Get a Groq API Key (Free, Recommended)
1. Go to: https://console.groq.com
2. Sign up for a free account
3. Generate an API key (starts with `gsk_...`)
4. Copy the key

#### Step 4: Configure Your API Key
Edit this file: `C:\Users\I526653\Documents\GitHub\droidclaw\.env`

Find this line:
```
GROQ_API_KEY=YOUR_GROQ_API_KEY_HERE
```

Replace `YOUR_GROQ_API_KEY_HERE` with your actual API key.

#### Step 5: Prepare Your Android Phone
1. Go to **Settings → About Phone**
2. Tap **Build Number** 7 times (enables Developer Options)
3. Go to **Settings → Developer Options**
4. Enable **USB Debugging**
5. Connect phone to computer via USB cable
6. On phone: Tap **Allow** when prompted about USB debugging

#### Step 6: Install Dependencies
Open a terminal in the droidclaw folder:
```bash
cd C:\Users\I526653\Documents\GitHub\droidclaw
bun install
```

#### Step 7: Verify Everything Works
```bash
# Check phone is connected
adb devices

# Should show your device like:
# List of attached devices
# ABC123456       device
```

```bash
# Test the agent (interactive mode)
bun run src/kernel.ts
```

When prompted, enter a simple test goal:
```
open settings
```

The agent should launch the Settings app on your phone!

---

## Using Your Custom Workflows

### Customize the Workflows

Before running, edit these files to replace `YOUR_NAME_HERE` with your actual WhatsApp contact name:

1. **Daily Report**: `examples/workflows/custom/daily-report.json`
2. **Monitor & Alert**: `examples/workflows/custom/monitor-and-alert.json`

Also update `com.example.targetapp` in monitor-and-alert.json to the actual app package name you want to monitor (e.g., `com.instagram.android`).

To find an app's package name:
```bash
# List all installed apps
adb shell pm list packages

# Or search for a specific app
adb shell pm list packages | grep -i instagram
```

### Run Daily Report Workflow
```bash
cd C:\Users\I526653\Documents\GitHub\droidclaw
bun run src/kernel.ts --workflow examples/workflows/custom/daily-report.json
```

This will:
1. Check Gmail for unread emails
2. Read today's calendar events
3. Get weather forecast
4. Send everything to you via WhatsApp

### Run Monitor & Alert Workflow
```bash
bun run src/kernel.ts --workflow examples/workflows/custom/monitor-and-alert.json
```

This will:
1. Open the target app
2. Check for notifications/updates
3. Send alerts to you via WhatsApp

---

## Scheduling Automated Runs

### Option 1: Windows Task Scheduler

1. Open **Task Scheduler**
2. Click **Create Basic Task**
3. Name: "DroidClaw Daily Report"
4. Trigger: **Daily** at 8:00 AM (or your preferred time)
5. Action: **Start a program**
   - Program: `C:\Users\<YourUsername>\.bun\bin\bun.exe` (find with `where bun`)
   - Arguments: `run src/kernel.ts --workflow examples/workflows/custom/daily-report.json`
   - Start in: `C:\Users\I526653\Documents\GitHub\droidclaw`
6. Finish

**Important**: Keep your phone plugged into USB and powered on for scheduled runs!

### Option 2: Wireless ADB (Advanced)

To run without USB cable:

1. Install Tailscale on both phone and computer
2. On phone: **Settings → Developer Options → Wireless Debugging**
3. Note the IP and port shown
4. Connect: `adb connect <phone-ip>:<port>`
5. Run workflows remotely

---

## Troubleshooting

### "bun: command not found"
- Restart your terminal after installing Bun
- Or find Bun path: `C:\Users\<YourUsername>\.bun\bin\bun.exe`

### "adb: command not found"
- Restart terminal after installing ADB
- Check PATH includes ADB directory

### "no devices/emulators found"
- USB debugging enabled on phone?
- USB cable supports data transfer (not just charging)?
- Did you tap "Allow" on phone?
- Try: `adb kill-server && adb start-server`

### "unauthorized device"
- Disconnect and reconnect USB
- Tap "Allow" on phone again
- Run: `adb devices`

### Agent keeps getting stuck
- Increase `STEP_DELAY` to 3-4 seconds in `.env`
- Some apps load slowly and need more time

### Can't find UI elements
- Set `VISION_MODE=always` in `.env`
- This uses screenshots instead of just accessibility tree
- More accurate but slower and uses more API tokens

### LLM rate limits
- Free Groq tier has limits
- Switch to local Ollama: Install from https://ollama.com
- Run: `ollama pull llama3.2-vision`
- In `.env`: Set `LLM_PROVIDER=ollama`

---

## Next Steps

1. **Test interactive mode** first with simple goals
2. **Customize the workflows** with your contacts and apps
3. **Run workflows manually** to test and refine
4. **Schedule automated runs** via Task Scheduler
5. **Monitor logs** in `droidclaw/logs/` to debug issues
6. **Expand workflows** - Add more apps and data sources!

---

## Useful Commands

```bash
# Interactive mode (type your goal)
bun run src/kernel.ts

# Run a specific workflow
bun run src/kernel.ts --workflow path/to/workflow.json

# Check connected devices
adb devices

# View logs (latest session)
cat logs/latest-session.json

# Find app package names
adb shell pm list packages | grep -i <app_name>

# Restart ADB if issues
adb kill-server && adb start-server
```

---

## Resources

- **DroidClaw Repo**: https://github.com/unitedbyai/droidclaw
- **Documentation**: `droidclaw/docs/`
- **Example Workflows**: `droidclaw/examples/workflows/` (35+ examples!)
- **Groq Console**: https://console.groq.com
- **ADB Download**: https://developer.android.com/tools/releases/platform-tools

---

## File Locations Summary

- **Main Config**: `C:\Users\I526653\Documents\GitHub\droidclaw\.env`
- **Daily Report Workflow**: `C:\Users\I526653\Documents\GitHub\droidclaw\examples\workflows\custom\daily-report.json`
- **Monitor & Alert Workflow**: `C:\Users\I526653\Documents\GitHub\droidclaw\examples\workflows\custom\monitor-and-alert.json`
- **Logs**: `C:\Users\I526653\Documents\GitHub\droidclaw\logs\`
- **Plan Reference**: `C:\Users\I526653\.claude\plans\enumerated-wiggling-bunny.md`

---

**You're almost ready to go!** Just install Bun, ADB, get your Groq API key, and you'll have an autonomous Android agent running in minutes. 🚀
