#!/usr/bin/env bash
set -e

# Codex CLI installer: OpenAI's terminal coding agent
TOOL="codex"

echo "Installing $TOOL (OpenAI Codex CLI)..."

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

# Install OpenAI Codex CLI globally
RUN bun install -g @openai/codex

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent

ENTRYPOINT ["codex"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ OpenAI's official terminal agent"
echo "  ✓ GPT-4 and Codex models"
echo "  ✓ Multi-file code generation"
echo "  ✓ Terminal command execution"
echo ""
echo "Usage: ai-run codex"
echo "Auth: Set OPENAI_API_KEY environment variable"
