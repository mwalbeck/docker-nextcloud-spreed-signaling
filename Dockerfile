FROM golang:1.21.8-bullseye@sha256:81d98548f08e22a59c5c0be814acc0997f3dfd3313487adcf4e1d3d962af3a43 as build

# renovate: datasource=github-tags depName=strukturag/nextcloud-spreed-signaling versioning=semver
ENV SPREED_SIGNALING_VERSION v1.2.3

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        protobuf-compiler \
    ; \
    git clone --branch $SPREED_SIGNALING_VERSION https://github.com/strukturag/nextcloud-spreed-signaling.git /build; \
    cd /build; \
    make build;

FROM debian:bullseye-slim@sha256:a165446a88794db4fec31e35e9441433f9552ae048fb1ed26df352d2b537cb96

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
