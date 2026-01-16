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

# Install minimal dependencies for the native binary
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Create worker user first
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace

USER agent
ENV HOME=/home/agent

# Install Claude Code as the agent user
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/agent/.claude/bin:$PATH"

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
