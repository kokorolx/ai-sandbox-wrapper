#!/usr/bin/env bash
set -e

# Generate ai-run wrapper script
mkdir -p "$HOME/bin"

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
  echo "⚠️  SECURITY WARNING: You are running $TOOL outside a whitelisted workspace."
  echo "   Current path: $CURRENT_DIR"
  echo ""
  echo "Allowing this path gives the AI container access to this folder."
  read -p "Do you want to whitelist the current directory? [y/N]: " CONFIRM

  if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "$CURRENT_DIR" >> "$WORKSPACES_FILE"
    echo "✅ Added $CURRENT_DIR to $WORKSPACES_FILE"
  else
    echo "❌ Operation cancelled. Access denied."
    echo "📁 Allowed workspaces:"
    cat "$WORKSPACES_FILE"
    exit 1
  fi
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

# Tool-specific config mounts (project-level takes precedence over global)
CONFIG_MOUNT=""
PROJECT_CONFIG="$CURRENT_DIR/.$TOOL.json"

if [[ -f "$PROJECT_CONFIG" ]]; then
  # Use project-level config if it exists
  CONFIG_MOUNT="-v $PROJECT_CONFIG:$CURRENT_DIR/.$TOOL.json:delegated"
else
  # Use global configs based on tool
  case "$TOOL" in
    amp)
      CONFIG_DIR="$HOME/.config/amp"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/amp:delegated"
      ;;
    opencode)
      CONFIG_DIR="$HOME/.config/opencode"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/opencode:delegated"
      ;;
    claude)
      CONFIG_DIR="$HOME/.claude"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.claude:delegated"
      ;;
    droid)
      CONFIG_DIR="$HOME/.config/droid"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/droid:delegated"
      ;;
    qoder)
      CONFIG_DIR="$HOME/.config/qoder"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/qoder:delegated"
      ;;
    auggie)
      CONFIG_DIR="$HOME/.config/auggie"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/auggie:delegated"
      ;;
    codebuddy)
      CONFIG_DIR="$HOME/.config/codebuddy"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/codebuddy:delegated"
      ;;
    jules)
      CONFIG_DIR="$HOME/.config/jules"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/jules:delegated"
      ;;
    shai)
      CONFIG_DIR="$HOME/.config/shai"
      mkdir -p "$CONFIG_DIR"
      CONFIG_MOUNT="-v $CONFIG_DIR:/home/agent/.config/shai:delegated"
      ;;
  esac
fi

docker run --rm -it \
  --platform linux/arm64 \
  $VOLUME_MOUNTS \
  $CONFIG_MOUNT \
  -v "$CACHE_DIR":/home/agent/.cache \
  -v "$HOME_DIR":/home/agent \
  -w "$CURRENT_DIR" \
  --env-file "$ENV_FILE" \
  "$IMAGE" "$@"
AIRUNEOF

chmod +x "$HOME/bin/ai-run"
echo "✅ ai-run wrapper script created at $HOME/bin/ai-run"
