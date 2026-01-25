FROM oven/bun:latest

# Install common dependencies (Bun + Node.js + Python for full package manager support)
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

# Install Node.js LTS (includes npm) via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally via npm
RUN npm install -g pnpm

# Verify installations
RUN node --version && npm --version && pnpm --version && bun --version

# Install additional tools (if selected)
RUN pipx install specify-cli --pip-args="git+https://github.com/github/spec-kit.git"
RUN bun install -g uipro-cli
RUN mkdir -p /usr/local/lib/openspec && \
    cd /usr/local/lib/openspec && \
    bun init -y && \
    bun add @fission-ai/openspec && \
    ln -sf /usr/local/lib/openspec/node_modules/.bin/openspec /usr/local/bin/openspec

# Create workspace
WORKDIR /workspace

# Non-root user for security
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace
USER agent
ENV HOME=/home/agent
