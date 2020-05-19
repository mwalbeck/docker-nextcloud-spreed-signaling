FROM debian:buster-slim

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
    ; \
    rm -rf /var/lib/apt/lists/*

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        make \
        git \
        python \
        golang \
    ; \
    \
    mkdir -p /build; \
    mkdir -p /app; \
    mkdir -p /config; \
    \
    git clone https://github.com/strukturag/nextcloud-spreed-signaling.git /build/signaling; \
    cd /build/signaling; \
    make build; \
    mv bin/signaling /app/signaling; \
    mv server.conf.in /config/server.conf; \
    \
    rm -rf /build; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*

CMD ["/app/signaling", "--config", "/config/server.conf"]
