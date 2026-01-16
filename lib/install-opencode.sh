#!/usr/bin/env bash
set -e

# OpenCode installer: Open-source AI coding tool (Native Go Binary)
TOOL="opencode"

echo "Installing $TOOL (OpenCode AI - Native Go Binary)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile using official native installer (Go binary)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM debian:bookworm-slim

# Install minimal dependencies for the native binary
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create worker user first
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace

USER agent
ENV HOME=/home/agent

# Install OpenCode as the agent user
RUN curl -fsSL https://opencode.ai/install | bash

ENTRYPOINT ["opencode"]
EOF

# Build image
echo "Building Docker image for $TOOL (native binary)..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed (Native Go Binary)"
echo ""
echo "Features:"
echo "  ✓ Native Go binary (no Node.js)"
echo "  ✓ Multi-model flexibility"
echo "  ✓ Terminal-based TUI workflow"
echo ""
echo "Usage: ai-run opencode"
