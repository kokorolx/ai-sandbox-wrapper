#!/usr/bin/env bash
set -e

# OpenCode installer: Open-source AI coding tool
TOOL="opencode"

echo "Installing $TOOL (OpenCode AI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
RUN bun install -g opencode-ai
USER agent
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
