#!/usr/bin/env bash
set -e

# Check and install dependencies
echo "Checking and installing dependencies..."

if ! command -v git &> /dev/null; then
    echo "Installing git..."
    apt-get update && apt-get install -y git
fi

if ! command -v python3 &> /dev/null; then
    echo "Installing python3..."
    apt-get install -y python3 python3-pip
fi

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker Desktop first."
    exit 1
fi

echo "🚀 AI Sandbox Setup (Docker Desktop + Node 22 LTS)"

read -p "Enter workspace directory to mount (e.g. $HOME/.workspace/code): " WORKSPACE

mkdir -p "$WORKSPACE"
mkdir -p "$HOME/bin"
mkdir -p "$HOME/ai-images/amp"
mkdir -p "$HOME/ai-images/opencode"
mkdir -p "$HOME/ai-images/droid"
mkdir -p "$HOME/.ai-cache/amp" "$HOME/.ai-cache/opencode" "$HOME/.ai-cache/droid"
mkdir -p "$HOME/.ai-home/amp" "$HOME/.ai-home/opencode" "$HOME/.ai-home/droid"

# Secrets
ENV_FILE="$HOME/.ai-env"
if [ ! -f "$ENV_FILE" ]; then
  cat <<EOF > "$ENV_FILE"
OPENAI_API_KEY=sk-xxx
ANTHROPIC_API_KEY=sk-xxx
EOF
  chmod 600 "$ENV_FILE"
  echo "⚠️  Edit $ENV_FILE with your real API keys"
fi

# ai-run script (workspace + cache + home persist)
cat <<EOF > "$HOME/bin/ai-run"
#!/usr/bin/env bash
set -e

TOOL="\$1"
shift

WORKSPACE="$WORKSPACE"
CURRENT_DIR="\$(pwd)"
ENV_FILE="$ENV_FILE"

if [[ "\$CURRENT_DIR" != "\$WORKSPACE"* ]]; then
  echo "❌ You must run AI tools inside \$WORKSPACE"
  exit 1
fi

IMAGE="ai-\${TOOL}:latest"

CACHE_DIR="\$HOME/.ai-cache/\$TOOL"
HOME_DIR="\$HOME/.ai-home/\$TOOL"

mkdir -p "\$CACHE_DIR" "\$HOME_DIR"

docker run --rm -it \\
  --platform linux/arm64 \\
  -v "\$WORKSPACE":"\$WORKSPACE":delegated \\
  -v "\$CACHE_DIR":/root/.cache \\
  -v "\$HOME_DIR":/root \\
  -v /tmp:/tmp \\
  -w "\$CURRENT_DIR" \\
  --env-file "\$ENV_FILE" \\
  "\$IMAGE" "\$@"
EOF

chmod +x "$HOME/bin/ai-run"

# PATH + aliases
SHELL_RC="$HOME/.zshrc"
grep -q 'ai-run' "$SHELL_RC" || cat <<EOF >> "$SHELL_RC"
export PATH="\$HOME/bin:\$PATH"
alias amp="ai-run amp"
alias opencode="ai-run opencode"
alias droid="ai-run droid"
EOF

# Amp Dockerfile
cat <<EOF > "$HOME/ai-images/amp/Dockerfile"
FROM node:22-slim
RUN npm install -g @sourcegraph/amp
WORKDIR /workspace
ENTRYPOINT ["amp"]
EOF

# OpenCode Dockerfile
cat <<EOF > "$HOME/ai-images/opencode/Dockerfile"
FROM node:22-slim
RUN npm install -g opencode-ai
WORKDIR /workspace
ENTRYPOINT ["opencode"]
EOF

# Droid Dockerfile
cat <<EOF > "$HOME/ai-images/droid/Dockerfile"
FROM node:22-slim
RUN npm install -g droid-factory
WORKDIR /workspace
ENTRYPOINT ["droid"]
EOF

# Build images
docker build -t ai-amp "$HOME/ai-images/amp"
docker build -t ai-opencode "$HOME/ai-images/opencode"
docker build -t ai-droid "$HOME/ai-images/droid"

echo ""
echo "✅ Setup complete!"
echo "➡ Restart terminal or run: source ~/.zshrc"
echo "➡ Add API keys to: $ENV_FILE"
echo "➡ Workspace locked to: $WORKSPACE"
echo ""
echo "📁 Per-project configs supported:"
echo "  .amp.json"
echo "  .opencode.json"
echo "  .droid.json"