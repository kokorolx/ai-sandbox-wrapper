#!/usr/bin/env bash
set -e

# VSCode installer: Fully containerized with X11 forwarding
TOOL="vscode"

echo "Installing $TOOL (fully containerized with X11 forwarding)..."

# Create directories
mkdir -p "$HOME/ai-images/$TOOL"
mkdir -p "$HOME/.ai-cache/$TOOL"
mkdir -p "$HOME/.ai-home/$TOOL"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Create Dockerfile for containerized VSCode
cat <<'EOF' > "$HOME/ai-images/$TOOL/Dockerfile"
FROM ubuntu:22.04

# Install VSCode and complete GUI stack
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    libx11-6 \
    libxext6 \
    libxrender1 \
    libxrandr2 \
    libxinerama1 \
    libxcursor1 \
    libxdamage1 \
    libxfixes3 \
    libxcomposite1 \
    libxkbcommon0 \
    libxkbfile1 \
    libgbm1 \
    libdrm2 \
    libdbus-1-3 \
    libnotify4 \
    libnspr4 \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcairo2 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libgdk-pixbuf2.0-0 \
    libfontconfig1 \
    libfreetype6 \
    libc6 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Download and extract VSCode
RUN ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then VSCODE_ARCH="x64"; elif [ "$ARCH" = "aarch64" ]; then VSCODE_ARCH="arm64"; else VSCODE_ARCH="x64"; fi && \
    echo "Downloading VSCode for ${VSCODE_ARCH}..." && \
    wget -q -O /tmp/vscode.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-${VSCODE_ARCH}" && \
    mkdir -p /opt && \
    tar -xzf /tmp/vscode.tar.gz -C /opt && \
    mv /opt/VSCode-linux-* /opt/vscode && \
    rm /tmp/vscode.tar.gz && \
    echo "VSCode installed successfully"

# Create directories
RUN mkdir -p /workspace /tmp
WORKDIR /workspace

# Non-root user (use UID 1001 to avoid conflicts)
RUN useradd -m -u 1001 vscode && \
    chown -R vscode:vscode /workspace /tmp /opt/vscode

USER vscode

# VSCode runs with --no-sandbox (already sandboxed by Docker)
ENTRYPOINT ["/opt/vscode/bin/code", "--no-sandbox", "--disable-gpu"]
CMD ["--new-window", "/workspace"]
EOF

# Build image
echo "Building Docker image for $TOOL..."
docker build -t "ai-$TOOL:latest" "$HOME/ai-images/$TOOL"

# Create wrapper script with X11 forwarding
cat <<'EOF' > "$HOME/bin/vscode-run"
#!/usr/bin/env bash
# Containerized VSCode launcher with X11 forwarding

set -e

WORKSPACES_FILE="$HOME/.ai-workspaces"
CONTAINER_NAME="ai-vscode-sandbox-$$"

if [ ! -f "$WORKSPACES_FILE" ]; then
    echo "Error: No workspaces configured. Run setup.sh first." >&2
    exit 1
fi

# Detect OS for X11 setup
OS_TYPE=$(uname -s)

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

echo "🔒 Starting containerized VSCode (strict sandbox)..."
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

# Setup X11 forwarding based on OS
if [ "$OS_TYPE" = "Darwin" ]; then
    # macOS: Check if XQuartz is running
    if ! pgrep -q Xvfb 2>/dev/null; then
        echo "⚠️  XQuartz not detected. Make sure it's running."
        echo "   Install: brew install xquartz"
        echo "   Or download: https://www.xquartz.org/"
        echo ""
    fi
    
    # Allow localhost connections to X11
    xhost + 127.0.0.1 2>/dev/null || true
    
    X11_SOCKET="/tmp/.X11-unix"
    X11_FORWARDING="-v /tmp/.X11-unix:$X11_SOCKET"
    X11_ENV="-e DISPLAY=host.docker.internal:0"
    
elif [ "$OS_TYPE" = "Linux" ]; then
    # Linux: Use host X11 socket
    X11_SOCKET="/tmp/.X11-unix"
    X11_FORWARDING="-v $X11_SOCKET:$X11_SOCKET"
    X11_ENV="-e DISPLAY=$DISPLAY"
fi

echo "🚀 Launching VSCode in sandbox container..."
echo ""

# STRICT SANDBOX SECURITY:
# - Read-only filesystem (except /workspace, /tmp)
# - No host environment variables (except DISPLAY)
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
    $X11_FORWARDING \
    $X11_ENV \
    --cap-drop=ALL \
    --security-opt=no-new-privileges:true \
    -e HOME=/workspace \
    -e PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    -u 1001:1001 \
    -w /workspace \
    "ai-vscode:latest"

echo ""
echo "🧹 VSCode container closed"
echo "✅ Sandbox cleaned up"
EOF

chmod +x "$HOME/bin/vscode-run"

echo "✅ $TOOL installed (fully containerized with X11)"
echo ""
echo "Created files:"
echo "  - Docker image: ai-$TOOL:latest"
echo "  - Wrapper script: $HOME/bin/vscode-run"
echo ""
echo "Security Features:"
echo "  ✓ Read-only filesystem (except /workspace, /tmp)"
echo "  ✓ No host environment variables visible"
echo "  ✓ No access to host filesystem outside volumes"
echo "  ✓ No elevated privileges (CAP_DROP=ALL)"
echo "  ✓ Runs as non-root user"
echo "  ✓ Terminal in VSCode is sandboxed"
echo ""
echo "Usage:"
echo "  vscode-run"
echo ""
echo "Requirements:"
if [ "$OS_TYPE" = "Darwin" ]; then
    echo "  ✓ macOS: Install XQuartz (brew install xquartz)"
else
    echo "  ✓ Linux: X11 display available (DISPLAY env var)"
fi
echo ""
echo "Whitelisted Workspaces:"
while IFS= read -r ws; do
    if [ -n "$ws" ] && [ -d "$ws" ]; then
        echo "  - $ws"
    fi
done < "$WORKSPACES_FILE"
