POV:

> - вы работаете в GOSYHE
> - астра лучшая ос
> - хочу лхс контейнеры
> - хочу виртуалки, но не хочу qemu-kvm+virt-manager
> - в проде нет интернета )))

---

# Развертывание

> Весь деплой подготовлен под отсутствие интернета и оффайл установку

## Загрузка

### Загрузить и подготовить архив

> Загружаем все необходимые файлы и создаем архив `incus.tar.gz`

`bash -c "$(curl -fsSL https://raw.githubusercontent.com/devil666face/astra-lxc-incus/main/download.sh)"`

### Или загрузить все руками

1. [Incus клиент](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus)

   - [оф. репа](https://github.com/lxc/incus/releases)

2. [Astra linux common edition 1.7.6 lxc контейнер для incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alce-incus-lxc-image.tar.gz)
3. [Astra linux special edition 1.7.6 lxc контейнер для incus](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/alse-incus-lxc-image.tar.gz)
4. [Все пакеты docker.io docker-cmpose для оффлайн установки на astra >1.7.0](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/docker-packages.tar.gz)
5. [Загруженный контейнер incus для docker](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-docker.tar.gz) [official repo](https://github.com/cmspam/incus-docker/pkgs/container/incus-docker)
6. [Incus migrate утилита](https://github.com/devil666face/astra-lxc-incus/releases/download/v0.0.0/incus-migrate)

   - [оф. репа](https://github.com/lxc/incus/releases)

```bash
tar -czvf incus.tar.gz install incus alce-incus-lxc-image.tar.gz alse-incus-lxc-image.tar.gz \
  docker-packages.tar.gz incus-docker.tar.gz incus-migrate
```

## Подготовка astrы

> Для деплоя incus необходима astra версии 1.7.0 и выше

Копируем созданный на предыдущем шаге `incus.tar.gz` на ноду под деплой и распаковываем

```bash
scp incus.tar.gz astra@192.168.200.150:~/
```

> Далее все комнады на удаленном хосте от суперпользователя

```bash
sudo su
tar -xf incus.tar.gz -C /tmp
cd /tmp

```

### Автоматизированная установка

Запускаем установщик подготовленный мной

```bash
chmod +x install
./install
```

В резульате вы получите примерно след.

```bash
2024/11/30 14:29:37 docker installed
2024/11/30 14:30:01 incus container runned
2024/11/30 14:30:02 incus inited
2024/11/30 14:30:02 save your cert
user: local
cert: eyJjbGllbnRfbmFtZSI6ImxvY2FsIiwiZmluZ2VycHJpbnQiOiIzZmRlNGI0MTMyY2EyZWNlY2RiNmU0NmIxNzZjNWQ1YmY5OTUxOTc1NWEzNDc3YzgwZTg0OTIwMDQ3YzJmYWNlIiwiYWRkcmVzc2VzIjpbIjE5Mi4xNjguMjAwLjE1MDo4NDQzIiwiMTcyLjE3LjAuMTo4NDQzIiwiMTkyLjE2OC4xMDAuMTo4NDQzIl0sInNlY3JldCI6IjkxOTEyMjNjZDU5OWU5NWY4ZDdjNWNhNjUwOWE5MjMyYzRjMmNjYjdhZGRiYmFiMWNmZGE4MTI0ZGRlYmRkNDUiLCJleHBpcmVzX2F0IjoiMDAwMS0wMS0wMVQwMDowMDowMFoifQ==
2024/11/30 14:30:06 astra images loaded
```

Все подробности и шаги, которые были проделаны вы можете прочитать в [README#Ручная установка]

#### Авторизуемся в веб интерфейсе

![Web auth](https://github.com/devil666face/astra-lxc-incus/raw/refs/heads/main/dist/import-cert.gif)

### Ручная установка

Ставим docker.io и docker-compose из оффлайн реп

```bash
tar -xf docker-packages.tar.gz -C /tmp
echo "deb [trusted=yes] file:/tmp/archives 1.7_x86-64 main" > /etc/apt/sources.list
apt-get update --yes
apt-get install docker.io docker-compose --yes
```

#### Развертывание incus

Загружаем docker image incus из архива и поднимем контейнер

```bash
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
```

#### Конфигурирование incus

1. Инициализируем первичную найстройку
2. Открываем порт для вебки
3. Создаем сертификат для пользователя `local` и подключения через клиентский бинарь incus

```bash
docker exec -it incus incus admin init
docker exec -it incus incus config set core.https_address :8443
docker exec -it incus incus config trust add local
```

1. Подключаем клиентский бинарь к серверу развернутом в docker контейнере
2. Переключаемся на управление с клиентского бинаря

```
incus remote add incus https://127.0.0.1:8443
incus remote switch incus
```

#### Загрузка lxc контейнеров в хранилище incus

## Развертывание lxc контейнеров

---

## Сборка lxc контейнера с ALSE/ALCE (опционально) и подготовка под incus

> Рекомендую использовать уже собранные и подготовленные контейнеры
> Работает на astra >=1.7.6

На отдельной виртуалке ([загрузить можно тут](https://dl.astralinux.ru/ui/native/mg-generic/alse/qemu/)) проводим след. манипуляции:

1. Ставим зависимости для lxc
2. Билдим lxc имейджи (займет много времени)

```bash
apt-get install lxc lxc-astra
lxc-create -t astralinux-ce -n alce
lxc-create -t astralinux-se -n alse
```

> Далее описаны действия для одного имейджа - alce (common edition) если вам необходим se (special edition), необходимы провести аналогичные действия, но заменив `alce` на `alse`
> Создаем файл метадаты для incus имейджа

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
  os: astra
  release: ce
  version: "1.7.6"
```

Пакуем готовый имейдж

```bash
tar -czvf alce.tar.gz metadata.yaml rootfs
```

Теперь можно использовать этот имейдж для загрузки в хранилище incus

```bash
incus image import alce.tar.gz --alias alce
```
