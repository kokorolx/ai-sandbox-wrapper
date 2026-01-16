#!/usr/bin/env bash
set -e

# Amp installer: Sourcegraph's AI coding assistant
TOOL="amp"

echo "Installing $TOOL (Sourcegraph Amp)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
ENV HOME=/home/agent
RUN curl -fsSL https://ampcode.com/install.sh | bash
RUN chown -R agent:agent /home/agent
# Native installer usually puts it in /usr/local/bin or similar root-accessible path
ENV PATH="/usr/local/bin:$PATH"
USER agent
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
