FROM ai-base:latest
USER root

# Install Jules CLI to a non-shadowed path
RUN mkdir -p /usr/local/lib/jules && \
    cd /usr/local/lib/jules && \
    bun init -y && \
    bun add @google/jules && \
    ln -s /usr/local/lib/jules/node_modules/.bin/jules /usr/local/bin/jules

USER agent
ENTRYPOINT ["jules"]
