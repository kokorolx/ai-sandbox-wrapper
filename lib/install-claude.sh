#!/usr/bin/env bash
set -e

# Claude Code installer: Anthropic's AI coding agent (Native Binary)
TOOL="claude"

echo "Installing $TOOL (Anthropic Claude Code - Native Binary)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile using official native installer (no npm needed)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM debian:bookworm-slim

USER root
ENV HOME=/home/agent
# Install Claude Code using official native installer
RUN curl -fsSL https://claude.ai/install.sh | bash
RUN chown -R agent:agent /home/agent

# Create workspace
WORKDIR /workspace

ENV PATH="/home/agent/.claude/bin:$PATH"
USER agent

ENTRYPOINT ["claude"]
EOF

# Build image
echo "Building Docker image for $TOOL (native binary)..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed (Native Binary)"
echo ""
echo "Features:"
echo "  ✓ Official native binary (no Node.js)"
echo "  ✓ Claude 3.5 Sonnet/Opus models"
echo "  ✓ Agentic coding with file editing"
echo "  ✓ Web search and fetch built-in"
echo ""
echo "Usage: ai-run claude"
echo "Auth: Set ANTHROPIC_API_KEY environment variable"
