# Schedule Daily Munich Weather at 9am

## What This Does

Every morning at 9am, your Honor 10 will:
1. Search for Munich weather
2. Collect temperature, forecast, conditions
3. Send to your Telegram

## Quick Setup (5 minutes)

### Step 1: Test It First

```bash
cd C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw
bash daily-munich-weather.sh
```

You should get a Telegram message with Munich weather!

### Step 2: Set Up Windows Task Scheduler

#### Open Task Scheduler
1. Press `Win + R`
2. Type: `taskschd.msc`
3. Press Enter

#### Create New Task
1. Click **"Create Basic Task"** (right side)
2. **Name**: `Daily Munich Weather`
3. **Description**: `Send Munich weather via Telegram at 9am`
4. Click **Next**

#### Set Trigger
1. Choose: **"Daily"**
2. Click **Next**
3. **Start**: Choose today's date
4. **Time**: `09:00:00` (9:00 AM)
5. **Recur every**: `1 days`
6. Click **Next**

#### Set Action
1. Choose: **"Start a program"**
2. Click **Next**
3. **Program/script**: `C:\Program Files\Git\bin\bash.exe`
4. **Add arguments**: `C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw\daily-munich-weather.sh`
5. **Start in**: `C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw`
6. Click **Next**

#### Finish
1. ✅ Check **"Open the Properties dialog"**
2. Click **Finish**

#### Configure Additional Settings (Important!)
In the Properties dialog that opens:

**General Tab**:
- ✅ Check: "Run whether user is logged on or not"
- ✅ Check: "Run with highest privileges"
- Select: "Configure for: Windows 10"

**Conditions Tab**:
- ❌ Uncheck: "Start the task only if the computer is on AC power"
- ✅ Check: "Wake the computer to run this task"

**Settings Tab**:
- ✅ Check: "Allow task to be run on demand"
- ✅ Check: "Run task as soon as possible after a scheduled start is missed"
- If task fails, restart every: `10 minutes` (3 attempts)
- Stop task if it runs longer than: `30 minutes`

Click **OK** to save.

---

## Testing the Schedule

### Test Manually (Without Waiting for 9am)
1. Open Task Scheduler
2. Find your task: "Daily Munich Weather"
3. Right-click → **"Run"**
4. Check Telegram for the weather message

### Check If It Ran
1. Open Task Scheduler
2. Find your task
3. Check **"Last Run Time"**
4. Check **"Last Run Result"** (should be 0x0 for success)

---

## Important Requirements

### ⚠️ Device Must Be:
- ✅ **Plugged in via USB** when task runs
- ✅ **Screen unlocked** (or no lock screen set)
- ✅ **USB debugging enabled**
- ✅ **Computer powered on** at 9am

### 💡 Tips:
- Set device to "Never sleep" when charging
- Disable lock screen temporarily
- Keep device face-up to avoid screen timeouts

---

## Customizing

### Change the Time
1. Task Scheduler → Find task → Properties
2. **Triggers** tab → Edit
3. Change time to your preference
4. Click OK

### Change the Location
Edit the workflow file:
[examples/workflows/custom/daily-munich-weather.json](file:///C:/Users/I526653/Documents/GitHub/personal_cnoetel/DroidClaw/examples/workflows/custom/daily-munich-weather.json)

Change line with `"weather Munich"` to:
```json
"goal": "Search for 'weather Berlin today'. Use read_screen..."
```

### Multiple Times Per Day
1. Task Scheduler → Find task → Properties
2. **Triggers** tab → **New**
3. Add additional times (e.g., 6pm for evening weather)

---

## Troubleshooting

### Task Says "Running" But Nothing Happens
1. Check device is connected: `adb devices`
2. Check device screen is unlocked
3. View task history: Task Scheduler → Task → History tab

### No Telegram Message Received
1. Check bot token in `.env` is correct
2. Test manually: `bash daily-munich-weather.sh`
3. Check logs: `C:\Users\I526653\Documents\GitHub\personal_cnoetel\DroidClaw\logs\`

### Task Failed (Exit Code Not 0)
1. Open Task Scheduler
2. Find task → **History** tab
3. Look for error messages
4. Common issues:
   - Device not connected
   - Screen locked
   - ADB not in PATH

### Computer Asleep at 9am
1. Task Properties → **Conditions** tab
2. ✅ Check: "Wake the computer to run this task"
3. In Windows Settings → Power → Additional power settings
4. Change sleep settings to allow wake timers

---

## Adding More Scheduled Tasks

Want more automation? Create additional tasks:

### Evening Summary (6pm)
```bash
# Create workflow: evening-summary.json
# Schedule: Daily at 6:00 PM
# Gets: Calendar events, notes, battery level
```

### Hourly Weather Updates
```bash
# Schedule: Hourly from 8am to 8pm
# Trigger: Repeat task every 1 hour for 12 hours
```

### Weekly Report (Monday 9am)
```bash
# Schedule: Weekly on Monday
# Gets: Week's calendar, accumulated notes
```

---

## Files Created

1. **[daily-munich-weather.json](file:///C:/Users/I526653/Documents/GitHub/personal_cnoetel/DroidClaw/examples/workflows/custom/daily-munich-weather.json)** - Workflow definition
2. **[daily-munich-weather.sh](file:///C:/Users/I526653/Documents/GitHub/personal_cnoetel/DroidClaw/daily-munich-weather.sh)** - Execution script

---

## Alternative: Cron-like Scheduling

For more complex schedules, you can use Windows Task Scheduler's advanced triggers:

**Every weekday at 9am**:
- Trigger → Weekly
- Select: Monday, Tuesday, Wednesday, Thursday, Friday

**First Monday of every month**:
- Trigger → Monthly
- Select: First week, Monday

**Multiple times**:
- Add multiple triggers to same task

---

## Example Task XML (Advanced)

If you want to export/import the task:
1. Task Scheduler → Find task → Export
2. Saves as XML file
3. Can import on another computer

---

## Success Checklist

After setup, verify:
- ✅ Task shows in Task Scheduler
- ✅ "Next Run Time" shows tomorrow at 9:00 AM
- ✅ Manual run works (sends Telegram message)
- ✅ Device stays connected overnight
- ✅ Computer won't sleep at 9am

**You're done!** 🎉 You'll get Munich weather every morning at 9am!

---

## Quick Reference

**Test now:**
```bash
bash daily-munich-weather.sh
```

**View task:**
- Task Scheduler → "Daily Munich Weather"

**Change time:**
- Properties → Triggers → Edit

**Disable temporarily:**
- Right-click task → Disable

**Re-enable:**
- Right-click task → Enable
