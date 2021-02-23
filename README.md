# docker-nextcloud-spreed-signaling

[![Build Status](https://build.walbeck.it/api/badges/walbeck-it/docker-nextcloud-spreed-signaling/status.svg)](https://build.walbeck.it/walbeck-it/docker-nextcloud-spreed-signaling)
![Docker Pulls](https://img.shields.io/docker/pulls/mwalbeck/nextcloud-spreed-signaling)

This is a docker image for the Spreed signaling server for Nextcloud Talk. The image has a debian base. You can find the image on [Docker Hub](https://hub.docker.com/r/mwalbeck/nextcloud-spreed-signaling) and the source code [here](https://git.walbeck.it/walbeck-it/docker-nextcloud-spreed-signaling) with a mirror on [github](https://github/mwalbeck/docker-nextcloud-spreed-signaling).

## Usage

To configure the signaling server you can mount your own config file to ```/config/server.conf``` inside the container. No other config options are available.

The container is run with a non-priveleged user ```signaling``` with an UID of 601. The container can be run with a read-only filesystem.

The ports used in the container are ```8088``` and ```8443``` for http and https communication respectively.

For more information about how to setup and use the signaling server itself, check out the projects [github repo](https://github.com/strukturag/nextcloud-spreed-signaling).
