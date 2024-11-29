POV:

> - вы работаете в GOSYHE
> - астра лучшая ос
> - хочу лхс контейнеры
> - хочу виртуалки, но не хочу qemu-kvm+virt-manager
> - в проде нет интернета )))

---

---

# Развертывание

> Весь деплой подготовлен под отсутствие интернета и оффайл установку

## Загрузка

### Загрузить и подготовить архив

> - Загружаем все необходимые файлы и создаем архив `incus.tar.gz`

- `bash -c "$(wget --no-cache https://github.com/devil666face/astra-lxc-incus/blob/main/download.sh -O -)"`
  или
- `bash -c "$(curl -fsSL https://raw.githubusercontent.com/devil666face/astra-lxc-incus/main/download.sh)"`

### Или загрузить все руками

1. [Incus клиент](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus) [оф. репа](https://github.com/lxc/incus/releases)
2. [Astra linux common edition 1.7.6 lxc контейнер для incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alce-incus-lxc-image.tar.gz)
3. [Astra linux special edition 1.7.6 lxc контейнер для incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alse-incus-lxc-image.tar.gz)
4. [Все пакеты docker.io docker-cmpose для оффлайн установки на astra >1.7.0](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/docker-packages.tar.gz)
5. [Загруженный контейнер incus для docker](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-docker.tar.gz) [official repo](https://github.com/cmspam/incus-docker/pkgs/container/incus-docker)
6. [Incus migrate утилита](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-migrate) [оф. репа](https://github.com/lxc/incus/releases)

```bash
tar -czvf incus.tar.gz install incus alce-incus-lxc-image.tar.gz alse-incus-lxc-image.tar.gz \
  docker-packages.tar.gz incus-docker.tar.gz incus-migrate
```

## Подготовка astrы

> Для деплоя incus необходима astra версии 1.7.0 и выше

Ставим docker.io и docker-compose

## Развертывание incus

## Конфигурирование incus

## Загрузка lxc контейнеров в хранилище incus

## Развертывание lxc контейнеров

---

> Рекомендую использовать уже собранные и подготовленные контейнеры

# Сборка lxc контейнера с ALSE/ALCE (опционально) и подготовка под incus
