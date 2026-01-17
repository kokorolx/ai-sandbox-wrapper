FROM ai-base:latest
USER root

# Install SHAI native binary and relocate to /usr/local/bin
RUN curl -fsSL https://raw.githubusercontent.com/ovh/shai/main/install.sh | bash && \
    mv /home/agent/.local/bin/shai /usr/local/bin/shai

USER agent
ENTRYPOINT ["shai"]
