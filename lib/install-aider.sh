#!/usr/bin/env bash
set -e

# Aider installer: Python-based AI coding assistant
TOOL="aider"

echo "Installing $TOOL (Python-based AI pair programmer)..."

# Create directories
mkdir -p "dockerfiles/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image which has Python)
cat <<'EOF' > "dockerfiles/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
# Install aider via pip
RUN pip install --no-cache-dir aider-chat
USER agent
ENTRYPOINT ["aider"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "dockerfiles/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Usage: ai-run aider [options]"
echo "Example: ai-run aider --model gpt-4"
