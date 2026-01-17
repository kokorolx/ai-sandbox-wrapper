FROM ai-base:latest
USER root
RUN mkdir -p /usr/local/lib/codex && \
    cd /usr/local/lib/codex && \
    bun init -y && \
    bun add @openai/codex && \
    ln -s /usr/local/lib/codex/node_modules/.bin/codex /usr/local/bin/codex
USER agent
ENTRYPOINT ["codex"]
