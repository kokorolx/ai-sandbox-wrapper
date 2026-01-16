#!/usr/bin/env bash
set -e

# Kilo Code installer: Multi-model AI coding agent
TOOL="kilo"

echo "Installing $TOOL (Kilo Code CLI)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile (extends base image for faster builds)
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
RUN bun install -g @kilocode/cli
USER agent
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
