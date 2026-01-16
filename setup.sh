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

WORKSPACES_FILE="$HOME/.ai-workspaces"

echo "Enter workspace directories to whitelist (comma-separated):"
echo "Example: $HOME/projects, $HOME/code, /opt/work"
read -p "Workspaces: " WORKSPACE_INPUT

# Parse and validate workspaces
IFS=',' read -ra WORKSPACE_ARRAY <<< "$WORKSPACE_INPUT"
WORKSPACES=()
for ws in "${WORKSPACE_ARRAY[@]}"; do
  ws=$(echo "$ws" | xargs)  # trim whitespace
  ws="${ws/#\~/$HOME}"      # expand ~ to $HOME
  if [[ -n "$ws" ]]; then
    mkdir -p "$ws"
    WORKSPACES+=("$ws")
  fi
done

if [[ ${#WORKSPACES[@]} -eq 0 ]]; then
  echo "❌ No valid workspaces provided"
  exit 1
fi

# Save workspaces to config file
printf "%s\n" "${WORKSPACES[@]}" > "$WORKSPACES_FILE"
chmod 600 "$WORKSPACES_FILE"
echo "📁 Whitelisted workspaces saved to: $WORKSPACES_FILE"

# Use first workspace as default for backwards compatibility
WORKSPACE="${WORKSPACES[0]}"

echo "Available AI tools:"
echo "  amp      - AI coding assistant from @sourcegraph/amp"
echo "  opencode - Open-source coding tool from opencode-ai"
echo "  droid    - Factory CLI from factory.ai"
echo "  claude   - Claude Code CLI from Anthropic"
echo ""
echo "Enter tools to install (comma-separated, or 'all' for everything):"
read -p "Tools: " SELECTED_TOOLS

# Parse selected tools
if [[ "$SELECTED_TOOLS" == "all" ]]; then
  TOOLS=("amp" "opencode" "droid" "claude")
else
  # Split by comma and trim spaces
  IFS=',' read -ra TOOL_ARRAY <<< "$SELECTED_TOOLS"
  TOOLS=()
  for tool in "${TOOL_ARRAY[@]}"; do
    tool=$(echo "$tool" | xargs)  # trim whitespace
    if [[ "$tool" =~ ^(amp|opencode|droid|claude)$ ]]; then
      TOOLS+=("$tool")
    else
      echo "Warning: Unknown tool '$tool', skipping..."
    fi
  done
fi

echo "Installing tools: ${TOOLS[*]}"

mkdir -p "$WORKSPACE"
mkdir -p "$HOME/bin"

# Install droid directly on host if selected
if [[ " ${TOOLS[@]} " =~ " droid " ]]; then
  echo "Installing Factory CLI (droid)..."
  if command -v curl &> /dev/null; then
    curl -fsSL https://app.factory.ai/cli | sh
    INSTALL_EXIT=$?
  else
    echo "❌ curl not found, cannot install Factory CLI"
    exit 1
  fi

  if [ $INSTALL_EXIT -eq 0 ]; then
    # Check if droid command is available
    if command -v droid &> /dev/null; then
      echo "✅ Factory CLI installed successfully"
      DROID_PATH=$(which droid)
      echo "📍 Factory CLI located at: $DROID_PATH"
    else
      echo "⚠️  Factory CLI installation completed, but 'droid' command not found in PATH"
      echo "   You may need to restart your terminal or add the installation directory to PATH"
      echo "   Trying to locate droid binary..."

      # Try to find droid in common locations
      DROID_FOUND=""
      for dir in "$HOME/.local/bin" "$HOME/bin" "/usr/local/bin" "/usr/bin"; do
        if [ -f "$dir/droid" ]; then
          DROID_FOUND="$dir/droid"
          echo "   Found droid at: $DROID_FOUND"
          break
        fi
      done

      if [ -n "$DROID_FOUND" ]; then
        echo "   Adding $DROID_FOUND to PATH..."
        export PATH="$PATH:$(dirname "$DROID_FOUND")"
        if ! grep -q "export PATH=.*$(dirname "$DROID_FOUND")" "$HOME/.zshrc"; then
          echo "export PATH=\"\$PATH:$(dirname "$DROID_FOUND")\"" >> "$HOME/.zshrc"
        fi
      else
        echo "   Could not locate droid binary. You may need to manually add it to PATH."
        echo "   Try running: source ~/.zshrc"
      fi
    fi
  else
    echo "❌ Failed to install Factory CLI"
    exit 1
  fi
fi

# Create directories for selected tools (skip droid as it's installed on host)
for tool in "${TOOLS[@]}"; do
  if [[ "$tool" != "droid" ]]; then
    mkdir -p "$HOME/ai-images/$tool"
    mkdir -p "$HOME/.ai-cache/$tool"
    mkdir -p "$HOME/.ai-home/$tool"
  fi
done

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
cat <<'AIRUNEOF' > "$HOME/bin/ai-run"
#!/usr/bin/env bash
set -e

TOOL="$1"
shift

WORKSPACES_FILE="$HOME/.ai-workspaces"
CURRENT_DIR="$(pwd)"
ENV_FILE="$HOME/.ai-env"

# Check if workspaces file exists
if [[ ! -f "$WORKSPACES_FILE" ]]; then
  echo "❌ Workspaces not configured. Run setup.sh first."
  exit 1
fi

# Check if current directory is inside any whitelisted workspace
ALLOWED=false
while IFS= read -r ws; do
  if [[ "$CURRENT_DIR" == "$ws"* ]]; then
    ALLOWED=true
    break
  fi
done < "$WORKSPACES_FILE"

if [[ "$ALLOWED" != "true" ]]; then
  echo "❌ You must run AI tools inside a whitelisted workspace"
  echo "📁 Allowed workspaces:"
  cat "$WORKSPACES_FILE"
  echo ""
  echo "💡 To add a folder: echo '/path/to/folder' >> $WORKSPACES_FILE"
  exit 1
fi

# Handle droid specially (installed on host)
if [[ "$TOOL" == "droid" ]]; then
  exec droid "$@"
fi

IMAGE="ai-${TOOL}:latest"

CACHE_DIR="$HOME/.ai-cache/$TOOL"
HOME_DIR="$HOME/.ai-home/$TOOL"

mkdir -p "$CACHE_DIR" "$HOME_DIR"

# Build volume mounts for all whitelisted workspaces
VOLUME_MOUNTS=""
while IFS= read -r ws; do
  VOLUME_MOUNTS="$VOLUME_MOUNTS -v $ws:$ws:delegated"
done < "$WORKSPACES_FILE"

docker run --rm -it \
  --platform linux/arm64 \
  $VOLUME_MOUNTS \
  -v "$CACHE_DIR":/root/.cache \
  -v "$HOME_DIR":/root \
  -w "$CURRENT_DIR" \
  --env-file "$ENV_FILE" \
  "$IMAGE" "$@"
AIRUNEOF

chmod +x "$HOME/bin/ai-run"

# PATH + aliases
SHELL_RC="$HOME/.zshrc"
if ! grep -q 'ai-run' "$SHELL_RC"; then
  echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$SHELL_RC"
  for tool in "${TOOLS[@]}"; do
    echo "alias $tool=\"ai-run $tool\"" >> "$SHELL_RC"
  done
fi

# Create Dockerfiles for selected tools (skip droid as it's installed on host)
for tool in "${TOOLS[@]}"; do
  if [[ "$tool" != "droid" ]]; then
    case $tool in
      amp)
        cat <<EOF > "$HOME/ai-images/$tool/Dockerfile"
FROM node:22-slim
RUN npm install -g @sourcegraph/amp
WORKDIR /workspace
ENTRYPOINT ["amp"]
EOF
        ;;
      opencode)
        cat <<EOF > "$HOME/ai-images/$tool/Dockerfile"
FROM node:22-slim
RUN npm install -g opencode-ai
WORKDIR /workspace
ENTRYPOINT ["opencode"]
EOF
        ;;
      claude)
        cat <<EOF > "$HOME/ai-images/$tool/Dockerfile"
FROM node:22-slim
RUN npm install -g @anthropic-ai/claude-code
WORKDIR /workspace
ENTRYPOINT ["claude"]
EOF
        ;;
    esac
  fi
done

# Build images for selected tools (skip droid as it's installed on host)
for tool in "${TOOLS[@]}"; do
  if [[ "$tool" != "droid" ]]; then
    echo "Building Docker image for $tool..."
    docker build -t "ai-$tool" "$HOME/ai-images/$tool"
  fi
done

echo ""
echo "✅ Setup complete!"
echo "➡ Restart terminal or run: source ~/.zshrc"
echo "➡ Add API keys to: $ENV_FILE"
echo ""
echo "📁 Whitelisted workspaces:"
for ws in "${WORKSPACES[@]}"; do
  echo "  $ws"
done
echo ""
echo "💡 Manage workspaces in: $WORKSPACES_FILE"
echo "   Add folder:    echo '/path/to/folder' >> $WORKSPACES_FILE"
echo "   Remove folder: Edit $WORKSPACES_FILE and delete the line"
echo "   List folders:  cat $WORKSPACES_FILE"
echo ""
echo "📁 Per-project configs supported:"
for tool in "${TOOLS[@]}"; do
  echo "  .$tool.json"
done