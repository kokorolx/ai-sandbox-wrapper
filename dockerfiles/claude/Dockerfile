FROM ai-base:latest

USER root
# Install Claude Code using official native installer
RUN curl -fsSL https://claude.ai/install.sh | bash && \
    mkdir -p /usr/local/share && \
    mv /home/agent/.local/share/claude /usr/local/share/claude && \
    ln -sf /usr/local/share/claude/versions/$(ls /usr/local/share/claude/versions | head -1) /usr/local/bin/claude

USER agent
ENTRYPOINT ["claude"]
