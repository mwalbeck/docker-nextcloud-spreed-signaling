FROM golang:1.23.7-bullseye@sha256:8731dcb40a7b879ccb493fa4fa38e83d9f33ca24ab60bec02e98d5af7e962cac as build

# renovate: datasource=github-tags depName=strukturag/nextcloud-spreed-signaling versioning=semver
ENV SPREED_SIGNALING_VERSION v2.0.2

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        protobuf-compiler \
    ; \
    git clone --branch $SPREED_SIGNALING_VERSION https://github.com/strukturag/nextcloud-spreed-signaling.git /build; \
    cd /build; \
    make build;

FROM debian:bullseye-slim@sha256:e4b93db6aad977a95aa103917f3de8a2b16ead91cf255c3ccdb300c5d20f3015

COPY --from=build /build/bin/signaling /usr/local/bin/signaling
COPY --from=build /build/server.conf.in /config/server.conf

RUN set -ex; \
    \
    groupadd --system --gid 601 signaling; \
    useradd --no-log-init --system --gid signaling --no-create-home --uid 601 signaling; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
    ; \
    rm -rf /var/lib/apt/lists/*;

USER signaling:signaling

EXPOSE 8088 8443

CMD ["/usr/local/bin/signaling", "--config", "/config/server.conf"]
