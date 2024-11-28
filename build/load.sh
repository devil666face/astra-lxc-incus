#!/bin/bash
ASTRA_RELEASE="1.7.6"
DOCKER_PKG="docker.io docker-compose"
UTIL_PKG="apt-mirror dpkg-dev debconf-utils apt-utils ca-certificates"

mkdir -p /tmp/archives
echo -e "
deb http://download.astralinux.ru/astra/frozen/1.7_x86-64/$ASTRA_RELEASE/uu/1/repository-base 1.7_x86-64 main contrib non-free
deb http://download.astralinux.ru/astra/frozen/1.7_x86-64/$ASTRA_RELEASE/uu/1/repository-extended 1.7_x86-64 main contrib non-free
" > /etc/apt/sources.list

apt update --yes && \
  apt-get --download-only upgrade --enable-upgrade --yes && \
  cp -r /var/cache/apt/archives/*.deb /tmp/archives

apt-get --download-only install $DOCKER_PKG --yes && \
  cp -r /var/cache/apt/archives/*.deb /tmp/archives

apt install $UTIL_PKG --yes

cd /tmp/archives
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
apt-ftparchive release . > Release

mkdir -p dists/1.7_x86-64/main/binary-all && \
  mkdir -p dists/1.7_x86-64/main/binary-amd64
cp Packages.gz dists/1.7_x86-64/main/binary-all && \
  cp Packages.gz dists/1.7_x86-64/main/binary-amd64 && \
  cp Release dists/1.7_x86-64/main/binary-all && \
  cp Release dists/1.7_x86-64/main/binary-amd64

cd /tmp
tar -cvzf docker-packages.tar.gz archives
cp docker-packages.tar.gz /data

