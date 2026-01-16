#!/usr/bin/env bash
set -e

# Codex CLI installer: OpenAI's terminal coding agent
TOOL="codex"

echo "Installing $TOOL (OpenAI Codex CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
ENV HOME=/home/agent
RUN bun install -g @openai/codex
RUN chown -R agent:agent /home/agent
ENV PATH="/home/agent/.bun/bin:$PATH"
USER agent
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
