#!/usr/bin/env bash
set -e

# Build base Docker image with Bun runtime (2x faster than Node.js)
mkdir -p "$HOME/ai-images/base"
cat <<'EOF' > "$HOME/ai-images/base/Dockerfile"
FROM oven/bun:latest

# Install common dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent
EOF

echo "Building base Docker image with Bun runtime..."
docker build -t "ai-base:latest" "$HOME/ai-images/base"
echo "✅ Base image built (ai-base:latest)"

