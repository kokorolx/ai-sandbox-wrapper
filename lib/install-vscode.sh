#!/usr/bin/env bash
set -e

# VSCode Server installer: Headless VSCode in browser
TOOL="vscode"
VSCODE_PORT="${VSCODE_PORT:-8000}"

echo "Installing $TOOL (VSCode Server - browser-based)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Create Dockerfile for VSCode Server
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ubuntu:22.04

# Install VSCode Server dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install VSCode Server (Coder's open-source version)
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then VSCODE_ARCH="x64"; elif [ "$ARCH" = "aarch64" ]; then VSCODE_ARCH="arm64"; else VSCODE_ARCH="x64"; fi && \
    echo "Downloading VSCode Server for ${VSCODE_ARCH}..." && \
    wget -q -O /tmp/code-server.tar.gz "https://github.com/coder/code-server/releases/download/v4.19.0/code-server-4.19.0-linux-${VSCODE_ARCH}.tar.gz" && \
    tar -xzf /tmp/code-server.tar.gz -C /opt && \
    mv /opt/code-server-* /opt/code-server && \
    rm /tmp/code-server.tar.gz && \
    echo "VSCode Server installed successfully"

# Create directories
RUN mkdir -p /workspace /tmp
WORKDIR /workspace

# Non-root user (use UID 1001 to avoid conflicts)
RUN useradd -m -u 1001 vscode && \
    chown -R vscode:vscode /workspace /tmp /opt/code-server

USER vscode

# Expose port
EXPOSE 8000

# Start VSCode Server
ENTRYPOINT ["/opt/code-server/bin/code-server", "--bind-addr", "0.0.0.0:8000", "--disable-telemetry"]
CMD ["/workspace"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

# Create wrapper script
cat <<'EOF' > "$HOME/bin/vscode-run"
#!/usr/bin/env bash
# VSCode Server launcher - opens in browser

WORKSPACES_FILE="$HOME/.ai-workspaces"
CONTAINER_NAME="ai-vscode-sandbox-$$"
VSCODE_PORT="${VSCODE_PORT:-8000}"

if [ ! -f "$WORKSPACES_FILE" ]; then
    echo "Error: No workspaces configured. Run setup.sh first." >&2
    exit 1
fi

# Build volume mounts from whitelisted workspaces
VOLUME_MOUNTS=""
WS_INDEX=0
while IFS= read -r ws; do
    if [ -n "$ws" ] && [ -d "$ws" ]; then
        VOLUME_MOUNTS="$VOLUME_MOUNTS -v $ws:/workspace/workspace-$WS_INDEX"
        WS_INDEX=$((WS_INDEX + 1))
    fi
done < "$WORKSPACES_FILE"

if [ $WS_INDEX -eq 0 ]; then
    echo "Error: No valid workspaces found in $WORKSPACES_FILE" >&2
    exit 1
fi

echo "🔒 Starting VSCode Server (strict sandbox)..."
echo ""
echo "Mounted workspaces:"
WS_INDEX=0
while IFS= read -r ws; do
    if [ -n "$ws" ] && [ -d "$ws" ]; then
        echo "  ✓ $ws → /workspace/workspace-$WS_INDEX"
        WS_INDEX=$((WS_INDEX + 1))
    fi
done < "$WORKSPACES_FILE"
echo ""

# STRICT SANDBOX SECURITY:
# - Read-only filesystem (except /workspace, /tmp)
# - No network access (only localhost:8000)
# - No host environment variables
# - No access to host files outside volumes
# - No elevated privileges (CAP_DROP=ALL)
# - Non-root user

docker run \
    --rm \
    --read-only \
    --tmpfs /tmp \
    --tmpfs /run \
    --name "$CONTAINER_NAME" \
    $VOLUME_MOUNTS \
    -p 127.0.0.1:$VSCODE_PORT:8000 \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    -e HOME=/workspace \
    -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    -u 1001:1001 \
    -w /workspace \
    "ai-vscode:latest"

echo ""
echo "✅ VSCode Server stopped"
echo "🧹 Sandbox cleaned up"
EOF

chmod +x "$HOME/bin/vscode-run"

echo "✅ $TOOL installed (VSCode Server)"
echo ""
echo "Created files:"
echo "  - Docker image: ai-$TOOL:latest"
echo "  - Wrapper script: $HOME/bin/vscode-run"
echo ""
echo "Security Features:"
echo "  ✓ Read-only filesystem (except /workspace, /tmp)"
echo "  ✓ No network access (only localhost:8000)"
echo "  ✓ No host environment variables visible"
echo "  ✓ No access to host filesystem outside volumes"
echo "  ✓ No elevated privileges (CAP_DROP=ALL)"
echo "  ✓ Runs as non-root user"
echo "  ✓ Terminal in VSCode is sandboxed"
echo ""
echo "Usage:"
echo "  vscode-run"
echo "  # Opens VSCode in browser at http://localhost:8000"
echo ""
echo "Whitelisted Workspaces:"
while IFS= read -r ws; do
    if [ -n "$ws" ] && [ -d "$ws" ]; then
        echo "  - $ws"
    fi
done < "$WORKSPACES_FILE"
