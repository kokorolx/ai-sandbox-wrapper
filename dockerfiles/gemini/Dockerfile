FROM ai-base:latest
USER root
RUN mkdir -p /usr/local/lib/gemini && \
    cd /usr/local/lib/gemini && \
    bun init -y && \
    bun add @google/gemini-cli && \
    ln -s /usr/local/lib/gemini/node_modules/.bin/gemini /usr/local/bin/gemini
USER agent
ENTRYPOINT ["gemini"]
