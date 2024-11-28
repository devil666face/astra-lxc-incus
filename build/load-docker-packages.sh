#!/bin/bash
shopt -s extglob  # Enable extended pattern matching

for file in !("data"|"python"|"pkg"|"venv"); do
  sudo cp -r "$file" data
done

docker run \
  --rm \
  -it \
  -v ./data:/data \
  registry.astralinux.ru/library/alse:1.7.5 \
  bash -c '/data/build/load.sh'
  
cp ./data/docker-packages.tar.gz .
