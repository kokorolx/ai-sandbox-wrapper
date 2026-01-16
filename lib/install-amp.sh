#!/usr/bin/env bash
set -e

# Amp installer: Sourcegraph's AI coding assistant
TOOL="amp"

echo "Installing $TOOL (Sourcegraph Amp)..."

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

# Install Amp CLI globally
RUN bun install -g @sourcegraph/amp

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent

ENTRYPOINT ["amp"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ Sourcegraph AI coding assistant"
echo "  ✓ Code understanding and generation"
echo "  ✓ Multi-file editing"
echo ""
echo "Usage: ai-run amp"
