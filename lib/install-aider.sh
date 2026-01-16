#!/usr/bin/env bash
set -e

# Aider installer: Python-based AI coding assistant
TOOL="aider"

echo "Installing $TOOL (Python-based AI pair programmer)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile for Aider (Python-based)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM python:3.12-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install pipx and aider using uv (fastest method)
RUN pip install --no-cache-dir pipx && \
    pipx ensurepath && \
    pipx install aider-chat

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace /root/.local
USER agent
ENV HOME=/home/agent
ENV PATH="/root/.local/bin:$PATH"

ENTRYPOINT ["aider"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Usage: ai-run aider [options]"
echo "Example: ai-run aider --model gpt-4"
