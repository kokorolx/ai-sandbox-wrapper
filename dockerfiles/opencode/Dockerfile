FROM ai-base:latest

USER root
# Install OpenCode using official native installer
RUN curl -fsSL https://opencode.ai/install | bash && \
    mv /home/agent/.opencode/bin/opencode /usr/local/bin/opencode && \
    rm -rf /home/agent/.opencode

USER agent
ENTRYPOINT ["opencode"]
