#!/usr/bin/env bash
set -e

echo "🔧 Installing OpenSpec..."

if ! command -v bun &> /dev/null && ! command -v node &> /dev/null; then
    echo "❌ Neither Bun nor Node.js found. Please install one of them first."
    exit 1
fi

if command -v bun &> /dev/null; then
    echo "📦 Installing @fission-ai/openspec using Bun..."
    bun install -g @fission-ai/openspec
else
    echo "📦 Installing @fission-ai/openspec using npm..."
    npm install -g @fission-ai/openspec
fi

echo "✅ OpenSpec installed successfully!"
echo ""
echo "Usage:"
echo "  openspec                   # Start interactive wizard"
echo "  openspec --help            # Show all options"
echo ""
echo "OpenSpec provides spec-driven development workflows"
echo "for AI coding assistants with structured specifications."
