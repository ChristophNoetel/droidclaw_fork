#!/data/data/com.termux/files/usr/bin/bash
# Termux Auto-Setup Script
# This runs inside Termux environment

echo "🚀 Starting Termux auto-configuration..."
echo ""

# Navigate to home
cd ~

# Update and upgrade packages
echo "📦 Step 1/9: Updating packages..."
yes | pkg update 2>&1 | grep -v "WARNING"
yes | pkg upgrade 2>&1 | grep -v "WARNING"

# Install essential packages
echo "📦 Step 2/9: Installing git, curl, wget, nodejs, jq..."
yes | pkg install git curl wget nodejs jq 2>&1 | grep -v "WARNING"

# Install Bun
echo "📦 Step 3/9: Installing Bun runtime..."
curl -fsSL https://bun.sh/install | bash

# Configure Bun PATH
echo "🔧 Step 4/9: Configuring environment..."
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

# Verify Bun installation
echo "✅ Verifying Bun..."
$HOME/.bun/bin/bun --version

# Clone DroidClaw
echo "📥 Step 5/9: Cloning DroidClaw..."
if [ -d ~/droidclaw ]; then
    echo "   DroidClaw already exists, pulling latest..."
    cd ~/droidclaw
    git pull
else
    git clone https://github.com/unitedbyai/droidclaw.git ~/droidclaw
    cd ~/droidclaw
fi

# Install dependencies
echo "📦 Step 6/9: Installing DroidClaw dependencies (932 packages)..."
$HOME/.bun/bin/bun install

# Copy .env from storage
echo "🔧 Step 7/9: Configuring .env..."
if [ -f /sdcard/droidclaw-env ]; then
    cp /sdcard/droidclaw-env ~/.droidclaw/.env || cp /sdcard/droidclaw-env ~/droidclaw/.env
    echo "   .env copied from /sdcard/droidclaw-env"
else
    echo "   ⚠️  Warning: /sdcard/droidclaw-env not found"
fi

# Copy telegram listener
echo "🤖 Step 8/9: Setting up Telegram listener..."
if [ -f /sdcard/telegram-listener.sh ]; then
    cp /sdcard/telegram-listener.sh ~/telegram-listener.sh
    chmod +x ~/telegram-listener.sh
    echo "   Telegram listener installed"
else
    echo "   ⚠️  Warning: /sdcard/telegram-listener.sh not found"
fi

# Install screen for persistent sessions
echo "📦 Step 9/9: Installing screen..."
yes | pkg install screen 2>&1 | grep -v "WARNING"

echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "Installed:"
echo "  • Git: $(git --version | head -1)"
echo "  • Node: $(node --version)"
echo "  • Bun: $($HOME/.bun/bin/bun --version)"
echo "  • DroidClaw: ~/droidclaw"
echo ""
echo "Next steps:"
echo "1. Test DroidClaw:"
echo "   cd ~/droidclaw"
echo "   ~/.bun/bin/bun run src/kernel.ts"
echo ""
echo "2. Start Telegram listener:"
echo "   screen -S agent"
echo "   ~/telegram-listener.sh"
echo "   (Press Ctrl+A then D to detach)"
echo ""
