FROM golang:1.23.2-bullseye@sha256:48ac5022f9740543cac0eba41a4e37b721073a0103349e416678e0142a53b49a as build

# renovate: datasource=github-tags depName=strukturag/nextcloud-spreed-signaling versioning=semver
ENV SPREED_SIGNALING_VERSION v2.0.1

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        protobuf-compiler \
    ; \
    git clone --branch $SPREED_SIGNALING_VERSION https://github.com/strukturag/nextcloud-spreed-signaling.git /build; \
    cd /build; \
    make build;

FROM debian:bullseye-slim@sha256:60a596681410bd31a48e5975806a24cd78328f3fd6b9ee5bc64dca6d46a51f29

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
