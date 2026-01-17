FROM ai-base:latest
USER root
RUN bash -c "curl -fsSL https://app.factory.ai/cli | sh" && \
    mv /home/agent/.local/bin/droid /usr/local/bin/droid
USER agent
ENTRYPOINT ["bash", "-c", "exec droid \"$@\"", "--"]
