FROM ai-base:latest
USER root

# Install Qoder CLI to a non-shadowed path
RUN mkdir -p /usr/local/lib/qoder && \
    cd /usr/local/lib/qoder && \
    bun init -y && \
    bun add @qoder-ai/qodercli && \
    ln -s /usr/local/lib/qoder/node_modules/.bin/qodercli /usr/local/bin/qoder

USER agent
ENTRYPOINT ["qoder"]
