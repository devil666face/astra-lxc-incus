POV:

> - you work at GOSYHE
> - Astra is the best OS
> - I want LXC containers
> - I want virtual machines, but I don't want qemu-kvm+virt-manager
> - there is no Internet in production )))

---

- ​​download everything with `wget` `bash -c "$(wget --no-cache https://github.com/devil666face/astra-lxc-incus/blob/main/download.sh -O -)"`

or

- `curl` `bash -c "$(curl -fsSL https://raw.githubusercontent.com/devil666face/astra-lxc-incus/main/download.sh)"`

or download

1. [Incus client](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus) [of. turnip](https://github.com/lxc/incus/releases)
2. [Astra linux common edition 1.7.6 lxc container for incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alce-incus-lxc-image.tar.gz)
3. [Astra linux special edition 1.7.6 lxc container for incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alse-incus-lxc-image.tar.gz)
4. [All docker.io docker-cmpose packages for offline installation on astra >1.7.0](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/docker-packages.tar.gz)
5. [Downloaded incus container for docker](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-docker.tar.gz) [official repo](https://github.com/cmspam/incus-docker/pkgs/container/incus-docker)
6. [Incus migrate utility](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-migrate) [of. repa](https://github.com/lxc/incus/releases)

```bash
tar -czvf incus.tar.gz install incus alce-incus-lxc-image.tar.gz alse-incus-lxc-image.tar.gz \
docker-packages.tar.gz incus-docker.tar.gz incus-migrate
```

---

# Preparing astra

> To deploy incus, you need astra version 1.7.0 or higher

Install docker.io and docker-compose

# Deploying incus

# Configuring incus

# Building an lxc container with ALSE/ALCE (optional) and preparing for incus

# Uploading lxc containers to the incus repository

# Deploying lxc containers
