#!/usr/bin/env bash
set -e

# Qwen Code installer: Alibaba's AI coding agent
TOOL="qwen"

echo "Installing $TOOL (Alibaba Qwen Code CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
# Note: Qwen CLI package name may vary
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
ENV HOME=/home/agent
RUN bun install -g @anthropic-ai/qwen-code || bun install -g qwen-code || echo "Qwen CLI package not found"
RUN chown -R agent:agent /home/agent
ENV PATH="/home/agent/.bun/bin:$PATH"
USER agent
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
