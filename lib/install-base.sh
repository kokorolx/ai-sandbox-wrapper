#!/usr/bin/env bash
set -e

# Build base Docker image with common dependencies
mkdir -p "$HOME/ai-images/base"
cat <<'EOF' > "$HOME/ai-images/base/Dockerfile"
FROM node:22-slim
RUN apt-get update && apt-get install -y \
    git \
    curl \
    ssh \
    build-essential \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /workspace
EOF

echo "Building base Docker image..."
docker build -t "ai-base:latest" "$HOME/ai-images/base"
