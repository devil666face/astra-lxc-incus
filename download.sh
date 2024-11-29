#!/bin/bash

# Set version
VERSION=0.0.0

# URLs to download
URLS=(
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/install"
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/incus"
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/alce-incus-lxc-image.tar.gz"
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/alse-incus-lxc-image.tar.gz"
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/docker-packages.tar.gz"
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/incus-docker.tar.gz"
  "https://github.com/devil666face/astra-lxc-incus/releases/download/v$VERSION/incus-migrate"
)

# Check if curl or wget exists
if command -v curl >/dev/null 2>&1; then
  echo "Using curl to download files..."
  for url in "${URLS[@]}"; do
    file=$(basename "$url")
    if [ -f "$file" ]; then
      echo "$file already exists, skipping download."
    else
      echo "Downloading $file..."
      curl -L -O "$url" || echo "Failed to download $url"
    fi
  done
elif command -v wget >/dev/null 2>&1; then
  echo "Using wget to download files..."
  for url in "${URLS[@]}"; do
    file=$(basename "$url")
    if [ -f "$file" ]; then
      echo "$file already exists, skipping download."
    else
      echo "Downloading $file..."
      wget "$url" || echo "Failed to download $url"
    fi
  done
else
  echo "Neither curl nor wget is installed. Please install one to proceed."
  exit 1
fi

# Create a tar.gz archive
echo "Creating incus.tar.gz with downloaded files..."
tar -czvf incus.tar.gz install incus alce-incus-lxc-image.tar.gz alse-incus-lxc-image.tar.gz \
  docker-packages.tar.gz incus-docker.tar.gz incus-migrate

echo "Archive created: incus.tar.gz"
