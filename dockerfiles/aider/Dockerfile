FROM ai-base:latest
USER agent
# Install aider via aider-install
RUN python3 -m pip install --break-system-packages aider-install && aider-install
ENTRYPOINT ["aider"]
