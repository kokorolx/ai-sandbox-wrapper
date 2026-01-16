#!/usr/bin/env bash
set -e

# Qoder CLI installer: Qoder's AI coding assistant
TOOL="qoder"

echo "Installing $TOOL (Qoder AI CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root

# Install Qoder CLI to a non-shadowed path
RUN mkdir -p /usr/local/lib/qoder && \
    cd /usr/local/lib/qoder && \
    bun init -y && \
    bun add @qoder-ai/qodercli && \
    ln -s /usr/local/lib/qoder/node_modules/.bin/qodercli /usr/local/bin/qoder

USER agent
ENTRYPOINT ["qoder"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Usage: ai-run qoder"
echo "Auth: Set QODER_API_KEY environment variable"
