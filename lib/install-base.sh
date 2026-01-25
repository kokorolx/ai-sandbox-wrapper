#!/usr/bin/env bash
set -e

# Build base Docker image with Bun runtime (2x faster than Node.js)
mkdir -p "dockerfiles/base"

ADDITIONAL_TOOLS_INSTALL=""

if [[ "${INSTALL_SPEC_KIT:-0}" -eq 1 ]]; then
  echo "📦 spec-kit will be installed in base image"
  ADDITIONAL_TOOLS_INSTALL+='RUN pipx install specify-cli --pip-args="git+https://github.com/github/spec-kit.git"
'
fi

if [[ "${INSTALL_UX_UI_PROMAX:-0}" -eq 1 ]]; then
  echo "📦 ux-ui-promax will be installed in base image"
  ADDITIONAL_TOOLS_INSTALL+='RUN npm install -g uipro-cli
'
fi

if [[ "${INSTALL_OPENSPEC:-0}" -eq 1 ]]; then
  echo "📦 OpenSpec will be installed in base image"
  ADDITIONAL_TOOLS_INSTALL+='RUN mkdir -p /usr/local/lib/openspec && \
    cd /usr/local/lib/openspec && \
    bun init -y && \
    bun add @fission-ai/openspec && \
    ln -sf /usr/local/lib/openspec/node_modules/.bin/openspec /usr/local/bin/openspec
'
fi

cat > "dockerfiles/base/Dockerfile" <<EOF
FROM oven/bun:latest

# Install common dependencies (Bun + Python for npm and pip tools)
RUN apt-get update && apt-get install -y --no-install-recommends \\
    git \\
    curl \\
    ssh \\
    ca-certificates \\
    python3 \\
    python3-pip \\
    python3-venv \\
    python3-dev \\
    python3-setuptools \\
    build-essential \\
    libopenblas-dev \\
    pipx \\
    && curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh \\
    && rm -rf /var/lib/apt/lists/* \\
    && pipx ensurepath

# Install additional tools (if selected)
${ADDITIONAL_TOOLS_INSTALL}
# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \\
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent
EOF

echo "Building base Docker image with Bun runtime..."
docker build -t "ai-base:latest" "dockerfiles/base"
echo "✅ Base image built (ai-base:latest)"

