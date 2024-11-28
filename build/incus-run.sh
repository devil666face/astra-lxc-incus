#!/bin/bash
docker load < incus-docker.tar.gz
docker run -d \
  --name incus \
  --privileged \
  --env SETIPTABLES=true \
  --restart unless-stopped \
  --network host \
  --pid=host \
  --cgroupns=host \
  --volume /parsecfs:/parsecfs \
  --volume /dev:/dev \
  --volume /var/lib/incus:/var/lib/incus \
  --volume /lib/modules:/lib/modules:ro \
  ghcr.io/cmspam/incus-docker:latest
