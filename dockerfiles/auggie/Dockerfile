FROM ai-base:latest
USER root

# Install Auggie CLI to a non-shadowed path
RUN mkdir -p /usr/local/lib/auggie && \
    cd /usr/local/lib/auggie && \
    bun init -y && \
    bun add @augmentcode/auggie && \
    ln -s /usr/local/lib/auggie/node_modules/.bin/auggie /usr/local/bin/auggie

USER agent
ENTRYPOINT ["auggie"]
