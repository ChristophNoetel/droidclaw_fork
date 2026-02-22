# Telegram Bot Listener - Two-Way Communication

## What This Does

Allows you to **control your Android device by messaging the Telegram bot**. Send a message to @AgentClausCN_bot and the agent will:
1. Receive your message
2. Execute it as a goal on the Honor 10
3. Send results back to you

## How to Use

### Start the Listener

```bash
cd C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw
bash telegram-listener.sh
```

You should see:
```
🤖 Agent Claus Telegram Listener Started
📱 Listening for commands from chat ID: 1476586973
💬 Send messages to @AgentClausCN_bot to control your device
🛑 Press Ctrl+C to stop
```

### Send Commands via Telegram

Open Telegram and message @AgentClausCN_bot:

**Examples:**
- `open calendar and read today's events`
- `check notepad for notes`
- `open settings and check battery level`
- `search for weather in Berlin`

### What Happens

1. **You send**: "open calendar and read today's events"
2. **Bot replies**: "⚙️ Processing: open calendar and read today's events"
3. **Agent executes**: Opens calendar on Honor 10, reads events
4. **Bot sends back**: "✅ Completed: [results]"

---

## Running as Background Service

### Option 1: PowerShell (Keeps terminal open)
```powershell
Start-Process bash -ArgumentList "C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw\telegram-listener.sh" -WindowStyle Hidden
```

### Option 2: Windows Task Scheduler (Auto-start on boot)

1. **Open Task Scheduler**
2. **Create Basic Task**
   - Name: "Agent Claus Listener"
   - Trigger: "At log on"
   - Action: Start a program
     - Program: `C:\Program Files\Git\bin\bash.exe`
     - Arguments: `C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw\telegram-listener.sh`
     - Start in: `C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw`

3. **Settings**:
   - ✅ Run whether user is logged on or not
   - ✅ Run with highest privileges
   - ✅ If task fails, restart every 10 minutes

### Option 3: Manual Start Each Session

Just run when you need it:
```bash
bash telegram-listener.sh
```

---

## Security Notes

### Authentication
- ✅ Only accepts commands from YOUR chat ID (1476586973)
- ✅ Other users cannot control your device
- ✅ Bot token is kept secure in .env

### Safety Features
- ⏱️ **Timeout**: Commands timeout after 3 minutes
- 🔒 **Rate limiting**: 1 second delay between polls
- ✅ **Error handling**: Errors sent back to you, not exposed

### Best Practices
- Don't share your bot with others
- Monitor which commands you send
- Keep device on trusted WiFi
- Stop listener when not needed

---

## Troubleshooting

### Listener Not Starting
```bash
# Check if .env is loaded
cd C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw
source .env
echo $TELEGRAM_BOT_TOKEN
```

### No Response from Bot
1. Check listener is running
2. Verify device is connected: `adb devices`
3. Check Telegram for error messages

### Commands Timing Out
- Increase timeout in script (line with `timeout 180`)
- Check device screen is unlocked
- Verify app you're trying to control is installed

---

## Supported Commands

### Device Control
- `open [app name]` - Opens any app
- `search for [query]` - Web search
- `check [app] for [info]` - Read data from apps

### Information Collection
- `read today's calendar`
- `check notepad notes`
- `get battery level`

### Custom Goals
Send any natural language goal! The AI agent will figure out how to accomplish it.

---

## Example Workflow

**Morning Routine (Automated via Listener):**

1. Wake up, send: `good morning`
   - Agent collects calendar + notes
   - Sends daily summary

2. Later: `remind me of 3pm meeting`
   - Agent checks calendar
   - Sends meeting details

3. Evening: `what did I note today?`
   - Agent opens notepad
   - Reads and sends notes

---

## Advanced: Custom Responses

Edit `telegram-listener.sh` to add custom commands:

```bash
# Around line 60, add:
if [[ "$MESSAGE_TEXT" == "status" ]]; then
    # Custom status check
    BATTERY=$(adb shell dumpsys battery | grep level)
    curl -s -X POST "..." -d "text=📱 Device Status: $BATTERY"
    continue
fi
```

---

## Differences: Listener vs Scheduled

| Feature | Telegram Listener | Scheduled Workflows |
|---------|------------------|-------------------|
| Trigger | Your messages | Time-based |
| Flexibility | Any goal on-demand | Pre-defined tasks |
| Setup | Run listener script | Windows Task Scheduler |
| Use Case | Interactive control | Automated routines |

**Best Approach**: Use BOTH
- **Listener** for on-demand control
- **Scheduled** for daily automation

---

## Next Steps

1. **Test it**: Start listener, send a simple command
2. **Set it to auto-start**: Add to Task Scheduler
3. **Create shortcuts**: Pin bash script to taskbar
4. **Monitor logs**: Check `logs/` for debugging

---

**Now you have full two-way communication with your Android agent!** 🤖💬
