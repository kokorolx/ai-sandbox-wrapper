#!/usr/bin/env bash
set -e

# Build base Docker image with Bun runtime (2x faster than Node.js)
mkdir -p "dockerfiles/base"
cat <<'EOF' > "dockerfiles/base/Dockerfile"
FROM oven/bun:latest

# Install common dependencies (Bun + Python for npm and pip tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-setuptools \
    build-essential \
    libopenblas-dev \
    pipx \
    && curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh \
    && rm -rf /var/lib/apt/lists/* \
    && pipx ensurepath

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent
EOF

echo "Building base Docker image with Bun runtime..."
docker build -t "ai-base:latest" "dockerfiles/base"
echo "✅ Base image built (ai-base:latest)"

