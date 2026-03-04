#!/bin/bash
# Daily Munich Weather - Run at 9am
# This script gets Munich weather and sends it via Telegram

cd "$(dirname "$0")"

# Load environment variables
if [ -f .env ]; then
    set -a
    source <(grep -v '^#' .env | sed 's/\r$//')
    set +a
fi

# Set PATH for ADB
export PATH="/c/Users/I526653/platform-tools/platform-tools:$PATH"

echo "☀️ Getting Munich weather..."

# Run the workflow
RESULT=$(/c/Users/I526653/.bun/bin/bun.exe run src/kernel.ts --workflow examples/workflows/custom/daily-munich-weather.json 2>&1)

# Check if successful
if [ $? -eq 0 ]; then
    echo "✅ Weather collected successfully"

    # Alternative: Send a simple message directly if workflow didn't send
    # Uncomment if needed:
    # curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    #     -d "chat_id=${TELEGRAM_CHAT_ID}" \
    #     -d "text=Good morning! ☀️ Munich weather report has been collected."
else
    echo "❌ Failed to get weather"

    # Send error notification
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d "chat_id=${TELEGRAM_CHAT_ID}" \
        -d "text=⚠️ Morning weather report failed. Check device connection."
fi
