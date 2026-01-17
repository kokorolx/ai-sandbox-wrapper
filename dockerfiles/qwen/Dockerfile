FROM ai-base:latest
USER root
# Install qwen-code in a dedicated directory and symlink to /usr/local/bin
RUN mkdir -p /usr/local/lib/qwen && \
    cd /usr/local/lib/qwen && \
    bun init -y && \
    bun add @qwen-code/qwen-code@latest tiktoken && \
    ln -s /usr/local/lib/qwen/node_modules/.bin/qwen /usr/local/bin/qwen
USER agent
ENTRYPOINT ["qwen"]
