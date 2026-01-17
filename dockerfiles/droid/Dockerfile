FROM ai-base:latest
USER root
RUN mkdir -p /home/agent/.factory && \
    bash -c "curl -fsSL https://app.factory.ai/cli | sh" && \
    mv /home/agent/.local/bin/droid /usr/local/bin/droid && \
    chown -R agent:agent /home/agent/.factory
USER agent
ENTRYPOINT ["bash", "-c", "exec droid \"$@\"", "--"]
