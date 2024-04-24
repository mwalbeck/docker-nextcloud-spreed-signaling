FROM golang:1.21.9-bullseye@sha256:e249f1c6bcb9bf18a7fab1b78456f91f5e0e6be80f71485efb8b1e1a5c72f3db as build

# renovate: datasource=github-tags depName=strukturag/nextcloud-spreed-signaling versioning=semver
ENV SPREED_SIGNALING_VERSION v1.2.4

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        protobuf-compiler \
    ; \
    git clone --branch $SPREED_SIGNALING_VERSION https://github.com/strukturag/nextcloud-spreed-signaling.git /build; \
    cd /build; \
    make build;

FROM debian:bullseye-slim@sha256:715354035496a48b9c4c8f146a6f751de70449913773038776eb1f3d01c93989

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
