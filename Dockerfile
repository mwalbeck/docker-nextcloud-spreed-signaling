FROM debian:buster-slim@sha256:e0a33348ac8cace6b4294885e6e0bb57ecdfe4b6e415f1a7f4c5da5fe3116e02

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    \
    groupadd --system --gid 601 signaling; \
    useradd --no-log-init --system --gid signaling --no-create-home --uid 601 signaling;

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        curl \
        make \
        git \
        python3 \
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
    chown -R signaling:signaling /app; \
    chown -R signaling:signaling /config; \
    \
    rm -rf /build; \
    \
    apt-mark auto '.*' > /dev/null; \
    apt-mark manual $savedAptMark; \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*;

USER signaling:signaling

CMD ["/app/signaling", "--config", "/config/server.conf"]
