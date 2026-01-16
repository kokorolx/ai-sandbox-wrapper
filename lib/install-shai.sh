#!/usr/bin/env bash
set -e

# SHAI CLI installer: OVHcloud's AI agent
TOOL="shai"

echo "Installing $TOOL (OVHcloud SHAI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root

# Install SHAI native binary and relocate to /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/ovh/shai/main/install.sh | bash && \
    mv /home/agent/.local/bin/shai /usr/local/bin/shai

USER agent
ENTRYPOINT ["shai"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Usage: ai-run shai"
