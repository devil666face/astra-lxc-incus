POV:

> - you work at GOSYHE
> - aster is the best wasp
> - I want LHS containers
> - I want virtual machines, but I don't want qemu-kvm+virt-manager
> - there is no internet in production )))

---

# Deployment

> The entire deployment is prepared for the absence of the Internet and off-file installation

## Loading

### Upload and prepare archive

> Download all the necessary files and create an archive `incus.tar.gz`

`bash -c "$(curl -fsSL https://raw.githubusercontent.com/devil666face/astra-lxc-incus/main/download.sh)"`

### Or upload everything manually

1. [Incus client](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus)

   - [of. turnip](https://github.com/lxc/incus/releases)

2. [Astra linux common edition 1.7.6 lxc container for incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alce-incus-lxc-image.tar. gz)
3. [Astra linux special edition 1.7.6 lxc container for incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alse-incus-lxc-image.tar. gz)
4. [All docker.io docker-cmpose packages for offline installation on astra >1.7.0](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/docker-packages.tar.gz)
5. [Downloaded incus container for docker](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-docker.tar.gz) [official repo](https:/ /github.com/cmspam/incus-docker/pkgs/container/incus-docker)
6. [Incus migrate utility](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-migrate)

   - [of. turnip](https://github.com/lxc/incus/releases)

```bash
tar -czvf incus.tar.gz install incus alce-incus-lxc-image.tar.gz alse-incus-lxc-image.tar.gz \
  docker-packages.tar.gz incus-docker.tar.gz incus-migrate
```

## Preparation of astra

> To deploy incus, you need astra version 1.7.0 or higher

Copy the `incus.tar.gz` created in the previous step to the node under deployment and unpack it

```bash
scp incus.tar.gz astra@192.168.200.150:~/
```

> Next, all commands on the remote host from the superuser

```bash
sudo su
tar -xf incus.tar.gz -C /tmp
cd /tmp

```

### Automated installation

Run the installer I prepared

```bash
chmod +x install
./install
```

As a result, you will get approximately the following.

```bash
2024/11/30 14:29:37 docker installed
2024/11/30 14:30:01 incus container runned
2024/11/30 14:30:02 incus initiated
2024/11/30 14:30:02 save your certificate
user: local
cert: eyJjbGllbnRfbmFtZSI6ImxvY2FsIiwiZmluZ2VycHJpbnQiOiIzZmRlNGI0MTMyY2EyZWNlY2RiNmU0NmIxNzZjNWQ1YmY5OT UxOTc1NWEzNDc3YzgwZTg0OTIwMDQ3YzJmYWNlIiwiYWRkcmVzc2VzIjpbIjE5Mi4xNjguMjAwLjE1MDo4NDQzIiwiMTcyLjE3 LjAuMTo4NDQzIiwiMTkyLjE2OC4xMDAuMTo4NDQzIl0sInNlY3JldCI6IjkxOTEyMjNjZDU5OWU5NWY4ZDdjNWNhNjUwOWE5Mj MyYzRjMmNjYjdhZGRiYmFiMWNmZGE4MTI0ZGRlYmRkNDUiLCJleHBpcmVzX2F0IjoiMDAwMS0wMS0wMVQwMDowMDowMFoifQ==
2024/11/30 14:30:06 astra images loaded
```

All the details and steps that were done you can read in [manual installation](#manual-installation)

#### Log in to the web interface

![Web auth](https://github.com/devil666face/astra-lxc-incus/raw/refs/heads/main/dist/import-cert.gif)

### Manual installation

We install docker.io and docker-compose from offline repo

```bash
tar -xf docker-packages.tar.gz -C /tmp
echo "deb [trusted=yes] file:/tmp/archives 1.7_x86-64 main" > /etc/apt/sources.list
apt-get update --yes
apt-get install docker.io docker-compose --yes
```

#### Deploying incus

Download docker image incus from the archive and start the container

```bash
docker load < incus-docker.tar.gz
docker run -d \
  --name incus \
  --privileged\
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
```

#### Configuring incus

1. Initialize the primary setup
2. Open the port for the webcam
3. Create a certificate for the `local` user and connect via the incus client binary

```bash
docker exec -it incus incus admin init
```

```
Would you like to use clustering? (yes/no) [default=no]:
Do you want to configure a new storage pool? (yes/no) [default=yes]:
Name of the new storage pool [default=default]: pool
Name of the storage backend to use (lvm, lvmcluster, btrfs, dir) [default=btrfs]: dir
Where should this storage pool store its data? [default=/var/lib/incus/storage-pools/pool]:
Would you like to create a new local network bridge? (yes/no) [default=yes]:
What should the new bridge be called? [default=incusbr0]: br0
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 192.168.100.1/24
Would you like to NAT IPv4 traffic on your bridge? [default=yes]:
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: none
Would you like the server to be available over the network? (yes/no) [default=no]:
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]:
Would you like a YAML "init" preseed to be printed? (yes/no) [default=no]:
```

```bash
docker exec -it incus incus config set core.https_address :8443
docker exec -it incus incus config trust add local
```

```
Client local certificate add token:
eyJjbGllbnRfbmFtZSI6ImxvY2FsIiwiZmluZ2VycHJpbnQiOiJkMmM3YzI3NWYzYjcyOTA2Njg3NjczOWZmZTI2MjliYTRjMGI0Njg4N2Y3ZDE yNGM1OWZlMmM2YzU0ZTEzNTUzIiwiYWRkcmVzc2VzIjpbIjEwLjIyNC4xNTguMTcxOjg0NDMiLCIxNzIuMTcuMC4xOjg0NDMiLCIxOTIuMTY4Lj EwMC4xOjg0NDMiLCIxOTIuMTY4LjIwMC4xOjg0NDMiLCIxOTIuMTY4LjEwMC4xOjg0NDMiXSwic2VjcmV0IjoiZGE2MzM2Mjk0ZmFkYTBhMDAwY 2RlZjI0Y2YwNzg1ZDQ4YTU4MWVjMDRlYTFmNGNiZDQ0MGQwMjU2MDdmNzc2ZCIsImV4cGlyZXNfYXQiOiIwMDAxLTAxLTAxVDAwOjAwOjAwWiJ9
```

1. Connect the client binary to the server deployed in a docker container
2. Switch to control from the client binary

```bash
incus remote add incus https://127.0.0.1:8443
```

```

Certificate fingerprint: d2c7c275f3b729066876739ffe2629ba4c0b46887f7d124c59fe2c6c54e13553
ok (y/n/[fingerprint])? y
Trust token for incus: eyJjbGllbnRfbmFtZSI6ImxvY2FsIiwiZmluZ2VycHJpbnQiOiJkMmM3YzI3NWYzYjcyOTA2Njg3NjczOWZmZTI2MjliYTRjMGI0Njg4N2Y3ZDE yNGM1OWZlMmM2YzU0ZTEzNTUzIiwiYWRkcmVzc2VzIjpbIjEwLjIyNC4xNTguMTcxOjg0NDMiLCIxNzIuMTcuMC4xOjg0NDMiLCIxOTIuMTY4Lj EwMC4xOjg0NDMiLCIxOTIuMTY4LjIwMC4xOjg0NDMiLCIxOTIuMTY4LjEwMC4xOjg0NDMiXSwic2VjcmV0IjoiZGE2MzM2Mjk0ZmFkYTBhMDAwY 2RlZjI0Y2YwNzg1ZDQ4YTU4MWVjMDRlYTFmNGNiZDQ0MGQwMjU2MDdmNzc2ZCIsImV4cGlyZXNfYXQiOiIwMDAxLTAxLTAxVDAwOjAwOjAwWiJ9
Client certificate now trusted by server: incus
```

```bash
incus remote switch incus
```

Checking the connection

```bash
incus info
```

If everything is ok, there will be a big conclusion.

```bash
config:
  core.https_address: :8443
api_extensions:
- storage_zfs_remove_snapshots
- container_host_shutdown_timeout
- container_stop_priority
```

If there is no connection

```bash
Error: The incus daemon doesn't appear to be started (socket path: /var/lib/incus/unix.socket)
```

#### Loading lxc containers into incus storage

## Deploying lxc containers

---

## Building lxc container with ALSE/ALCE (optional) and preparing for incus

> I recommend using already assembled and prepared containers
> Works on astra >=1.7.6

On a separate virtual machine ([you can download it here](https://dl.astralinux.ru/ui/native/mg-generic/alse/qemu/)) we perform the following manipulations:

1. Install dependencies for lxc
2. Build lxc images (will take a lot of time)

```bash
apt-get install lxc lxc-astra
lxc-create -t ​​astralinux-ce -n alce
lxc-create -t ​​astralinux-se -n alse
```

> The following describes the actions for one image - alce (common edition) if you need se (special edition), you need to perform similar actions, but replacing `alce` with `alse`
> Create a metadata file for the incus image

```
cd /var/lib/lxc/alce/
touch metadata.yaml
```

`metadata.yaml`

```yaml
architecture: x86_64
creation_date: 1690000000
properties:
  description: "Astra linux common edition"
  OS: Astra
  release: ce
  version: "1.7.6"
```

We pack the finished image

```bash
tar -czvf alce.tar.gz metadata.yaml rootfs
```

Now you can use this image to upload to the incus repository

```bash
incus image import alce.tar.gz --alias alce
```
