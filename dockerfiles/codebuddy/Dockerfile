FROM ai-base:latest
USER root

# Install CodeBuddy CLI to a non-shadowed path
RUN mkdir -p /usr/local/lib/codebuddy && \
    cd /usr/local/lib/codebuddy && \
    bun init -y && \
    bun add @tencent-ai/codebuddy-code && \
    ln -s /usr/local/lib/codebuddy/node_modules/.bin/codebuddy /usr/local/bin/codebuddy

USER agent
ENTRYPOINT ["codebuddy"]
