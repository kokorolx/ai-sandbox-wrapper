#!/usr/bin/env bash
set -e

# OpenCode installer: Open-source AI coding tool (Native Go Binary)
TOOL="opencode"

echo "Installing $TOOL (OpenCode AI - Native Go Binary)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile using official native installer (Go binary)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest

USER root
# Install OpenCode using official native installer
RUN curl -fsSL https://opencode.ai/install | bash && \
    mv /home/agent/.opencode/bin/opencode /usr/local/bin/opencode && \
    rm -rf /home/agent/.opencode

USER agent
ENTRYPOINT ["opencode"]
EOF

# Build image
echo "Building Docker image for $TOOL (native binary)..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed (Native Go Binary)"
echo ""
echo "Features:"
echo "  ✓ Native Go binary (no Node.js)"
echo "  ✓ Multi-model flexibility"
echo "  ✓ Terminal-based TUI workflow"
echo ""
echo "Usage: ai-run opencode"
