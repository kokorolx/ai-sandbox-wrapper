#!/usr/bin/env bash
set -e

# Jules CLI installer: Google's AI coding assistant
TOOL="jules"

echo "Installing $TOOL (Google Jules CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root

# Install Jules CLI to a non-shadowed path
RUN mkdir -p /usr/local/lib/jules && \
    cd /usr/local/lib/jules && \
    bun init -y && \
    bun add @google/jules && \
    ln -s /usr/local/lib/jules/node_modules/.bin/jules /usr/local/bin/jules

USER agent
ENTRYPOINT ["jules"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Usage: ai-run jules"
