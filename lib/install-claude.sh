#!/usr/bin/env bash
set -e

# Claude Code installer: Anthropic's AI coding agent
TOOL="claude"

echo "Installing $TOOL (Anthropic Claude Code)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
RUN bun install -g @anthropic-ai/claude-code
USER agent
ENTRYPOINT ["claude"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ Anthropic's official CLI agent"
echo "  ✓ Claude 3.5 Sonnet/Opus models"
echo "  ✓ Agentic coding with file editing"
echo "  ✓ Web search and fetch built-in"
echo ""
echo "Usage: ai-run claude"
echo "Auth: Set ANTHROPIC_API_KEY environment variable"
