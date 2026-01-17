FROM ai-base:latest
USER root
# Install Amp globally into a persistent directory (not shadowed by home)
RUN mkdir -p /usr/local/lib/amp && \
    cd /usr/local/lib/amp && \
    bun init -y && \
    bun add @sourcegraph/amp && \
    ln -s /usr/local/lib/amp/node_modules/.bin/amp /usr/local/bin/amp
USER agent
ENTRYPOINT ["amp"]
