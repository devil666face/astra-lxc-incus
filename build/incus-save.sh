#!/bin/bash
docker pull ghcr.io/cmspam/incus-docker:latest
docker save ghcr.io/cmspam/incus-docker:latest | gzip > incus-docker.tar.gz
