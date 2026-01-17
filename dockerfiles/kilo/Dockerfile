FROM node:22-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ssh \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Kilo Code CLI as root
RUN npm install -g @kilocode/cli

# Create workspace
WORKDIR /workspace

# Create worker user
RUN useradd -m -u 1001 -d /home/agent agent && \
    chown -R agent:agent /workspace

USER agent
ENV HOME=/home/agent

# Kilo uses 'kilocode' as entrypoint
ENTRYPOINT ["kilocode"]
