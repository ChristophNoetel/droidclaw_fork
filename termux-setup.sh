#!/data/data/com.termux/files/usr/bin/bash
# Termux Setup Script for DroidClaw Autonomous Agent
# Run this script inside Termux on your Honor 10

set -e  # Exit on error

echo "🚀 Setting up Termux for DroidClaw..."

# Update package repositories
echo "📦 Updating packages..."
pkg update -y
pkg upgrade -y

# Install essential packages
echo "📦 Installing essential packages..."
pkg install -y git curl wget nodejs

# Install Bun runtime
echo "📦 Installing Bun..."
curl -fsSL https://bun.sh/install | bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Add Bun to bashrc for persistence
echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc
echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

# Verify installations
echo "✅ Verifying installations..."
git --version
node --version
bun --version

# Create DroidClaw directory
echo "📁 Creating DroidClaw directory..."
mkdir -p ~/droidclaw
cd ~/droidclaw

echo ""
echo "✅ Termux environment setup complete!"
echo ""
echo "Next steps:"
echo "1. Clone DroidClaw: git clone https://github.com/unitedbyai/droidclaw.git ~/droidclaw"
echo "2. Install dependencies: cd ~/droidclaw && bun install"
echo "3. Configure .env file"
echo ""
