#!/usr/bin/env bash
set -e

echo "🔧 Installing spec-kit..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

echo "📦 Installing @letuscode/spec-kit..."
npm install -g @letuscode/spec-kit

echo "✅ spec-kit installed successfully!"
echo ""
echo "Usage:"
echo "  speckit                    # Start interactive wizard"
echo "  speckit --help            # Show all options"
echo ""
echo "This will create spec-driven development templates and workflows"
echo "for your AI coding assistant."