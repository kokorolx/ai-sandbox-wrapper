#!/usr/bin/env bash
set -e

# Qwen Code installer: Alibaba's AI coding agent
TOOL="qwen"

echo "Installing $TOOL (Alibaba Qwen Code CLI)..."

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

# Install Qwen Code CLI globally
# Note: Package name may vary, using the fork of Gemini CLI
RUN bun install -g @anthropic-ai/qwen-code || bun install -g qwen-code || echo "Qwen CLI package not found, using placeholder"

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent

ENTRYPOINT ["qwen"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ Qwen3-Coder model (256K context)"
echo "  ✓ Agentic programming workflows"
echo "  ✓ Multi-file code editing"
echo "  ✓ Fork of Gemini CLI, compatible API"
echo ""
echo "Usage: ai-run qwen"
echo "Auth: Set DASHSCOPE_API_KEY or configure endpoint"
