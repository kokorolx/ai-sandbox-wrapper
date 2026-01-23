#!/usr/bin/env bash
set -e

echo "🎨 Installing UI UX Pro Max..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

echo "📦 Installing uipro-cli..."
npm install -g uipro-cli

echo "✅ UI UX Pro Max installed successfully!"
echo ""
echo "Usage:"
echo "  uipro install              # Install UI/UX design intelligence"
echo "  uipro --help              # Show all options"
echo ""
echo "This provides design intelligence for building professional UI/UX"
echo "across multiple platforms with 57 UI styles, 95 color palettes,"
echo "and 56 font pairings."