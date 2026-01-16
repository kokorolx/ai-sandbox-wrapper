#!/usr/bin/env bash
set -e

# Generic tool installer: ./install-tool.sh <tool> <npm-package> <entrypoint>
# Uses Bun runtime for 2x faster startup
TOOL="$1"
NPM_PACKAGE="$2"
ENTRYPOINT="${3:-$TOOL}"

if [[ -z "$TOOL" || -z "$NPM_PACKAGE" ]]; then
  echo "Usage: $0 <tool> <npm-package> [entrypoint]"
  exit 1
fi

echo "Installing $TOOL..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Create Dockerfile using Bun
cat <<EOF > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
USER root
RUN mkdir -p /usr/local/lib/$TOOL && \
    cd /usr/local/lib/$TOOL && \
    bun init -y && \
    bun add $NPM_PACKAGE && \
    ln -s /usr/local/lib/$TOOL/node_modules/.bin/$ENTRYPOINT /usr/local/bin/$ENTRYPOINT
USER agent
ENTRYPOINT ["$ENTRYPOINT"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"

