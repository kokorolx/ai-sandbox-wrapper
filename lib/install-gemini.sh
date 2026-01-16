#!/usr/bin/env bash
set -e

# Gemini CLI installer: Google's AI coding agent
TOOL="gemini"

echo "Installing $TOOL (Google Gemini CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
RUN bun install -g @google/gemini-cli
USER agent
ENTRYPOINT ["gemini"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ Free tier with Gemini 2.5 Pro"
echo "  ✓ MCP (Model Context Protocol) support"
echo "  ✓ Google Search grounding"
echo ""
echo "Usage: ai-run gemini"
echo "Auth: Set GOOGLE_API_KEY or use 'gemini auth'"
