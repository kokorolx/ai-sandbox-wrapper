#!/usr/bin/env bash
set -e

echo "Installing droid (Factory CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/droid"
mkdir -p "$HOME/.ai-cache/droid"
mkdir -p "$HOME/.ai-home/droid"

# Create Dockerfile with curl install
cat <<'EOF' > "$HOME/ai-images/droid/Dockerfile"
FROM ai-base:latest
USER root
ENV HOME=/home/agent
RUN bash -c "curl -fsSL https://app.factory.ai/cli | sh"
RUN chown -R agent:agent /home/agent
ENV PATH="/home/agent/.local/bin:$PATH"
USER agent
ENTRYPOINT ["bash", "-c", "exec droid \"$@\"", "--"]
EOF

# Build image
echo "Building Docker image for droid..."
docker build -t "ai-droid:latest" "$HOME/ai-images/droid"

echo "✅ droid installed"
