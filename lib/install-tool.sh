#!/usr/bin/env bash
set -e

# Generic tool installer: ./install-tool.sh <tool> <npm-package> <entrypoint>
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

# Create Dockerfile
cat <<EOF > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ai-base:latest
RUN npm install -g $NPM_PACKAGE
ENTRYPOINT ["$ENTRYPOINT"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

echo "✅ $TOOL installed"
