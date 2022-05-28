FROM golang:1.17.10-bullseye@sha256:02d011857cdef09ae2ffc03668d045261c2ab69a6a78d2a71bc8ec7263aa3c9c as build

# renovate: datasource=github-tags depName=strukturag/nextcloud-spreed-signaling versioning=semver
ENV SPREED_SIGNALING_VERSION v0.4.1

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
    ; \
    git clone --branch $SPREED_SIGNALING_VERSION https://github.com/strukturag/nextcloud-spreed-signaling.git /build; \
    cd /build; \
    make build;

FROM debian:bullseye-slim@sha256:06a93cbdd49a265795ef7b24fe374fee670148a7973190fb798e43b3cf7c5d0f

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
