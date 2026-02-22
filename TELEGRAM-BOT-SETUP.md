# Telegram Bot Setup Guide

## Step 1: Create Your Telegram Bot (2 minutes)

### On Your Main Device (Phone/Computer with Telegram):

1. **Open Telegram** on your main device
2. **Search for** `@BotFather` in Telegram search
3. **Start a chat** with BotFather
4. **Send command**: `/newbot`
5. **Choose a name** for your bot (e.g., "DroidClaw Agent")
6. **Choose a username** (must end in 'bot', e.g., `droidclaw_agent_bot`)

### BotFather will respond with:

```
Done! Congratulations on your new bot.
You will find it at t.me/your_bot_username

Use this token to access the HTTP API:
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz123456789

For a description of the Bot API, see this page:
https://core.telegram.org/bots/api
```

**IMPORTANT: Copy the token** (the long string with numbers and letters)

## Step 2: Get Your Chat ID

### Method 1: Using Your Main Device

1. **Start a chat** with your new bot (click the link from BotFather)
2. **Send any message** to the bot (e.g., "Hello")
3. **Open this URL** in your browser (replace YOUR_BOT_TOKEN with the token from BotFather):
   ```
   https://api.telegram.org/botYOUR_BOT_TOKEN/getUpdates
   ```
4. **Find your chat_id** in the response - it will look like:
   ```json
   {
     "update_id": 123456789,
     "message": {
       "message_id": 1,
       "from": {
         "id": 987654321,  <-- This is your CHAT_ID
         "is_bot": false,
         "first_name": "Your Name",
         ...
       },
       "chat": {
         "id": 987654321,  <-- This is your CHAT_ID
         ...
       }
     }
   }
   ```

5. **Copy the chat_id** number (e.g., 987654321)

### Method 2: Using @userinfobot (Easier)

1. **Search for** `@userinfobot` in Telegram
2. **Start the bot** and it will immediately show your User ID
3. **Copy your User ID** - this is your chat_id

## Step 3: Test Your Bot (Optional but Recommended)

Test if the bot can send you messages:

```bash
curl -X POST \
  "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/sendMessage" \
  -d "chat_id=<YOUR_CHAT_ID>" \
  -d "text=Hello from DroidClaw Agent!"
```

You should receive a message from your bot!

## Step 4: Configure DroidClaw

You'll add these values to the `.env` file:

```
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz123456789
TELEGRAM_CHAT_ID=987654321
```

## Step 5: Configure Bot on Tablet (No Account Needed!)

The beauty of this setup: **The tablet doesn't need to log into Telegram!**

The agent will use the **Bot API directly** via HTTP requests. This means:
- ✅ No personal account on the tablet
- ✅ No SIM card needed
- ✅ Bot sends messages to your main device
- ✅ Maximum privacy and security

## Bot vs Account Comparison

| Feature | Bot (Our Setup) | Personal Account |
|---------|----------------|------------------|
| Login on tablet | ❌ Not needed | ✅ Required |
| SIM card | ❌ Not needed | ✅ Usually required |
| Phone number | ❌ Not needed | ✅ Required |
| Privacy | ✅ Maximum | ⚠️ Uses your account |
| Security | ✅ Separate credentials | ⚠️ Full account access |

## Security Notes

- **Token security**: Keep your bot token secret (like a password)
- **Bot limitations**: Bots can only send messages, can't read your chats
- **Revoke anytime**: Delete bot via BotFather if compromised
- **No personal data**: Bot doesn't have access to your Telegram account

---

## Ready When You Are!

Once you have:
1. ✅ Bot token (from BotFather)
2. ✅ Your chat ID (from userinfobot or getUpdates)

I'll configure the workflows and test the system!
