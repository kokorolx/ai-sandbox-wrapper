FROM ai-base:latest

USER root
# Install OpenCode using npm for latest version
RUN npm install -g opencode-ai@latest

USER agent
ENTRYPOINT ["opencode"]
