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
echo "  amp        - AI coding assistant from @sourcegraph/amp"
echo "  opencode   - Open-source coding tool from opencode-ai"
echo "  droid      - Factory CLI from factory.ai"
echo "  claude     - Claude Code CLI from Anthropic"
echo "  gemini     - Google Gemini CLI (free tier, MCP support)"
echo "  kilo       - Kilo Code (500+ models, parallel agents)"
echo "  qwen       - Alibaba Qwen CLI (256K context)"
echo "  codex      - OpenAI Codex terminal agent"
echo "  aider      - AI pair programmer (Git-native)"
echo "  vscode     - VSCode Desktop in Docker (X11, requires XQuartz)"
echo "  codeserver - VSCode in browser (fast, no X11 needed)"
echo ""
echo "Enter tools to install (comma-separated, or 'all' for everything):"
read -p "Tools: " SELECTED_TOOLS

# Parse selected tools
if [[ "$SELECTED_TOOLS" == "all" ]]; then
  TOOLS=("amp" "opencode" "droid" "claude" "gemini" "kilo" "qwen" "codex" "aider" "vscode" "codeserver")
else
  # Split by comma and trim spaces
  IFS=',' read -ra TOOL_ARRAY <<< "$SELECTED_TOOLS"
  TOOLS=()
  for tool in "${TOOL_ARRAY[@]}"; do
    tool=$(echo "$tool" | xargs)  # trim whitespace
    if [[ "$tool" =~ ^(amp|opencode|droid|claude|gemini|kilo|qwen|codex|aider|vscode|codeserver)$ ]]; then
      TOOLS+=("$tool")
    else
      echo "Warning: Unknown tool '$tool', skipping..."
    fi
  done
fi

echo "Installing tools: ${TOOLS[*]}"

mkdir -p "$WORKSPACE"
mkdir -p "$HOME/bin"

# Secrets
ENV_FILE="$HOME/.ai-env"
if [ ! -f "$ENV_FILE" ]; then
  cat <<EOF > "$ENV_FILE"
OPENAI_API_KEY=[REDACTED:api-key]
ANTHROPIC_API_KEY=[REDACTED:api-key]
EOF
  chmod 600 "$ENV_FILE"
  echo "⚠️  Edit $ENV_FILE with your real API keys"
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install base image if any containerized tools selected (vscode doesn't need it)
NEEDS_BASE_IMAGE=0
for tool in "${TOOLS[@]}"; do
  if [[ "$tool" =~ ^(amp|opencode|claude)$ ]]; then
    NEEDS_BASE_IMAGE=1
    break
  fi
done

if [[ $NEEDS_BASE_IMAGE -eq 1 ]]; then
  bash "$SCRIPT_DIR/lib/install-base.sh"
fi

# Install selected tools
for tool in "${TOOLS[@]}"; do
  case $tool in
    amp)
      bash "$SCRIPT_DIR/lib/install-amp.sh"
      ;;
    opencode)
      bash "$SCRIPT_DIR/lib/install-opencode.sh"
      ;;
    droid)
      bash "$SCRIPT_DIR/lib/install-droid.sh"
      ;;
    claude)
      bash "$SCRIPT_DIR/lib/install-claude.sh"
      ;;
    gemini)
      bash "$SCRIPT_DIR/lib/install-gemini.sh"
      ;;
    kilo)
      bash "$SCRIPT_DIR/lib/install-kilo.sh"
      ;;
    qwen)
      bash "$SCRIPT_DIR/lib/install-qwen.sh"
      ;;
    codex)
      bash "$SCRIPT_DIR/lib/install-codex.sh"
      ;;
    aider)
      bash "$SCRIPT_DIR/lib/install-aider.sh"
      ;;
    vscode)
      bash "$SCRIPT_DIR/lib/install-vscode.sh"
      ;;
    codeserver)
      bash "$SCRIPT_DIR/lib/install-codeserver.sh"
      ;;
  esac
done

# Generate ai-run wrapper
bash "$SCRIPT_DIR/lib/generate-ai-run.sh"

# PATH + aliases
SHELL_RC="$HOME/.zshrc"

# Add PATH if not already present
if ! grep -q 'export PATH="\$HOME/bin:\$PATH"' "$SHELL_RC" 2>/dev/null; then
  echo "export PATH=\"\$HOME/bin:\$PATH\"" >> "$SHELL_RC"
fi

# Add aliases for each tool (only if not already present)
for tool in "${TOOLS[@]}"; do
  if [[ "$tool" == "vscode" ]]; then
    # VSCode Desktop uses vscode-run wrapper
    if ! grep -q "alias vscode=" "$SHELL_RC" 2>/dev/null; then
      echo "alias vscode='vscode-run'" >> "$SHELL_RC"
    fi
  elif [[ "$tool" == "codeserver" ]]; then
    # code-server uses codeserver-run wrapper
    if ! grep -q "alias codeserver=" "$SHELL_RC" 2>/dev/null; then
      echo "alias codeserver='codeserver-run'" >> "$SHELL_RC"
    fi
  else
    # Other tools use ai-run wrapper
    if ! grep -q "alias $tool=" "$SHELL_RC" 2>/dev/null; then
      echo "alias $tool=\"ai-run $tool\"" >> "$SHELL_RC"
    fi
  fi
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "🛠️  Installed tools:"
for tool in "${TOOLS[@]}"; do
  if [[ "$tool" == "vscode" ]]; then
    echo "  vscode-run (or: vscode) - Desktop VSCode via X11"
  elif [[ "$tool" == "codeserver" ]]; then
    echo "  codeserver-run (or: codeserver) - Browser VSCode at localhost:8080"
  else
    echo "  ai-run $tool (or: $tool)"
  fi
done
echo ""
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
  echo "  .$tool.json (overrides global config in $HOME/.config/$tool or $HOME/.$tool)"
done
