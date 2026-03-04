#!/bin/bash
# Telegram Bot Message Sender for DroidClaw
# Usage: ./send-telegram-message.sh "Your message here"

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if bot token and chat ID are set
if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Error: TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID must be set in .env"
    exit 1
fi

# Get message from command line argument or stdin
if [ -n "$1" ]; then
    MESSAGE="$1"
else
    MESSAGE=$(cat)
fi

# URL encode the message (basic implementation)
MESSAGE_ENCODED=$(echo -n "$MESSAGE" | jq -sRr @uri)

# Send message via Telegram Bot API
RESPONSE=$(curl -s -X POST \
    "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    -d "chat_id=${TELEGRAM_CHAT_ID}" \
    -d "text=${MESSAGE}" \
    -d "parse_mode=HTML")

# Check if successful
if echo "$RESPONSE" | grep -q '"ok":true'; then
    echo "✓ Message sent successfully"
    exit 0
else
    echo "✗ Failed to send message"
    echo "$RESPONSE"
    exit 1
fi
