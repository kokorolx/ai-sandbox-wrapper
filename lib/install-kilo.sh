#!/usr/bin/env bash
set -e

# Kilo Code installer: Multi-model AI coding agent
TOOL="kilo"

echo "Installing $TOOL (Kilo Code CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM oven/bun:latest

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Kilo Code CLI globally
RUN bun install -g @kilocode/cli

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent

# Kilo uses 'kilocode' as entrypoint
ENTRYPOINT ["kilocode"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
echo ""
echo "Features:"
echo "  ✓ 500+ AI models supported"
echo "  ✓ Parallel agents with git worktrees"
echo "  ✓ Orchestrator mode for complex tasks"
echo "  ✓ Multiple modes: ask, architect, code, debug"
echo ""
echo "Usage: ai-run kilo"
echo "Modes: ai-run kilo --mode architect"
