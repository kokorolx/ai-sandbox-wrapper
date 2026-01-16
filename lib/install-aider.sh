#!/usr/bin/env bash
set -e

# Aider installer: Python-based AI coding assistant
TOOL="aider"

echo "Installing $TOOL (Python-based AI pair programmer)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image which has Python)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
ENV HOME=/home/agent
# Install aider via pipx as root into agent's home
RUN pipx install aider-chat
RUN chown -R agent:agent /home/agent
ENV PATH="/home/agent/.local/bin:$PATH"
USER agent
ENTRYPOINT ["aider"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Usage: ai-run aider [options]"
echo "Example: ai-run aider --model gpt-4"
