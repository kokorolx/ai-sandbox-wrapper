#!/usr/bin/env bash
set -e

# OpenCode installer: Open-source AI coding tool
TOOL="opencode"

echo "Installing $TOOL (OpenCode AI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM oven/bun:latest

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCode CLI globally
RUN bun install -g opencode-ai

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent

ENTRYPOINT ["opencode"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ Open-source AI coding tool"
echo "  ✓ Multi-model flexibility"
echo "  ✓ Terminal-based workflow"
echo ""
echo "Usage: ai-run opencode"
