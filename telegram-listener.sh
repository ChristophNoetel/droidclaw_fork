#!/bin/bash
# Telegram Bot Polling Script - Listen for commands and execute DroidClaw
# Usage: ./telegram-listener.sh

# Change to DroidClaw directory
cd "$(dirname "$0")"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if bot token and chat ID are set
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Error: TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must be set in .env"
    exit 1
fi

# Set PATH for ADB
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

# Keep track of last processed update
LAST_UPDATE_ID=0

echo "🤖 Agent Claus Telegram Listener Started"
echo "📱 Listening for commands from chat ID: $TELEGRAM_CHAT_ID"
echo "💬 Send messages to @AgentClausCN_bot to control your device"
echo "🛑 Press Ctrl+C to stop"
echo ""

# Main polling loop
while true; do
    # Get updates from Telegram
    RESPONSE=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=${LAST_UPDATE_ID}&timeout=30")

    # Check if we got any updates
    RESULT_COUNT=$(echo "$RESPONSE" | grep -o '"result":\[.*\]' | wc -c)

    if [ $RESULT_COUNT -gt 15 ]; then
        # Parse the updates (simple approach - gets last message)
        MESSAGE_TEXT=$(echo "$RESPONSE" | grep -o '"text":"[^"]*"' | tail -1 | sed 's/"text":"//;s/"$//')
        UPDATE_ID=$(echo "$RESPONSE" | grep -o '"update_id":[0-9]*' | tail -1 | sed 's/"update_id"://')
        FROM_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | sed 's/"id"://')

        # Check if this is a new message from the authorized user
        if [ ! -z "$MESSAGE_TEXT" ] && [ "$FROM_ID" == "$TELEGRAM_CHAT_ID" ] && [ "$UPDATE_ID" != "$LAST_UPDATE_ID" ]; then

            # Update last processed ID
            LAST_UPDATE_ID=$((UPDATE_ID + 1))

            # Ignore bot commands we don't handle
            if [[ "$MESSAGE_TEXT" == "/start" ]] || [[ "$MESSAGE_TEXT" == "/help" ]]; then
                curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                    -d "chat_id=${TELEGRAM_CHAT_ID}" \
                    -d "text=Agent Claus - Commands:

Send me any natural language goal and I'll execute it on your Honor 10.

Examples:
- open calendar and read today's events
- check notepad for notes
- open settings and check battery level

I'll send you the results when done!" > /dev/null
                continue
            fi

            echo "📨 Received command: $MESSAGE_TEXT"

            # Send acknowledgment
            curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                -d "chat_id=${TELEGRAM_CHAT_ID}" \
                -d "text=⚙️ Processing: $MESSAGE_TEXT" > /dev/null

            # Execute DroidClaw with the goal
            echo "🤖 Executing DroidClaw..."
            RESULT=$(echo "$MESSAGE_TEXT" | timeout 180 /c/Users/I526653/.bun/bin/bun.exe run src/kernel.ts 2>&1 | tail -50)

            # Check if execution was successful
            if [ $? -eq 0 ]; then
                # Extract the final result (last few lines)
                SUMMARY=$(echo "$RESULT" | grep -E "(Success|Done|Completed|Result)" | tail -5)

                if [ -z "$SUMMARY" ]; then
                    SUMMARY="Task completed. Check device for results."
                fi

                # Send results back
                curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                    -d "chat_id=${TELEGRAM_CHAT_ID}" \
                    -d "text=✅ Completed: $MESSAGE_TEXT

Result:
$SUMMARY" > /dev/null

                echo "✅ Task completed successfully"
            else
                # Send error message
                curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                    -d "chat_id=${TELEGRAM_CHAT_ID}" \
                    -d "text=❌ Error executing: $MESSAGE_TEXT

The task timed out or encountered an error. Check device connection." > /dev/null

                echo "❌ Task failed or timed out"
            fi

            echo ""
        fi
    fi

    # Small delay to avoid hammering the API
    sleep 1
done
