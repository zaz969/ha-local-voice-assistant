FROM ghcr.io/ohf-voice/linux-voice-assistant:1.1.10

RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
    apulse \
    alsa-utils \
    libasound2 \
    libasound2-plugins \
    pulseaudio \
    pulseaudio-utils \
    pipewire-bin \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Copy run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

COPY override/ /app/override

ENTRYPOINT []
CMD ["/run.sh"]