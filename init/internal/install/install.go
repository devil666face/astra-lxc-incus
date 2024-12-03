package install

import (
	"fmt"
	"install/pkg/fs"
	"install/pkg/shell"
	"log"
	"strings"
	"time"
)

const (
	certFind    = "Client local certificate add token:\n"
	remoteFind  = "https://127.0.0.1:8443"
	sourcesList = `
deb [trusted=yes] file:/tmp/archives 1.7_x86-64 main
`
	micDisableCMD = "astra-mic-control disable"
)

var config = `
config:
  core.https_address: :8443
networks:
- config:
    ipv4.address: 192.168.100.1/24
    ipv4.nat: "true"
    ipv6.address: none
  description: ""
  name: br0
  type: bridge
  project: default
storage_pools:
- config:
    source: /var/lib/incus/storage-pools/pool
  description: ""
  name: pool
  driver: dir
profiles:
- config: {}
  description: Default Incus profile
  devices:
    eth0:
      name: eth0
      network: br0
      type: nic
    root:
      path: /
      pool: pool
      type: disk
  name: default
projects:
- config:
    features.images: "true"
    features.networks: "true"
    features.networks.zones: "true"
    features.profiles: "true"
    features.storage.buckets: "true"
    features.storage.volumes: "true"
  description: Default Incus project
  name: default
`

var dockerCMDs = []string{
	"/usr/bin/tar -xf docker-packages.tar.gz -C /tmp",
	"/usr/bin/apt-get update --yes",
	"/usr/bin/apt-get install docker.io docker-compose --yes",
}

type Install struct {
	path       string
	disablemic bool
}

func New(_path string, _disablemic bool) *Install {
	return &Install{
		path:       _path,
		disablemic: _disablemic,
	}
}

func (i *Install) Run() error {
	steps := []func() error{
		i.copyBin,
		i.installDocker,
		i.importImage,
		i.initIncus,
		i.loadImages,
	}

	for _, step := range steps {
		if err := step(); err != nil {
			return err
		}
	}
	if _, err := shell.FromString(fmt.Sprintf("cp %s /var/lib/incus/", "incus-migrate")).WithDir(i.path).Run(); err != nil {
		return fmt.Errorf("failed to copy in /usr/local/bin: %w", err)
	}
	if i.disablemic {
		if _, err := shell.FromString(micDisableCMD).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("failed to disable mic control: %w", err)
		}
	}
	return nil
}

func (i *Install) copyBin() error {
	for _, b := range []string{"incus", "incus-migrate"} {
		if _, err := shell.FromString(fmt.Sprintf("chmod +x %s", b)).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("failed to +x for %s: %w", b, err)
		}
		if _, err := shell.FromString(fmt.Sprintf("cp %s /usr/local/bin", b)).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("failed to copy %s in /usr/local/bin: %w", b, err)
		}
	}
	return nil
}

func (i *Install) installDocker() error {
	if err := fs.WriteFile("/etc/apt/sources.list", []byte(sourcesList)); err != nil {
		return fmt.Errorf("failed to writes sources.list: %w", err)
	}
	for _, c := range dockerCMDs {
		if _, err := shell.FromString(c).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("docker install error: %w", err)
		}
	}
	log.Println("docker installed")
	return nil
}

func (i *Install) importImage() error {
	var (
		dockerPsCMD  = "docker ps -a --format '{{.Names}}'"
		dockerRunCMD = `docker run --detach --tty
 --name incus
 --privileged
 --env SETIPTABLES=true
 --restart unless-stopped
 --network host
 --pid=host
 --cgroupns=host
 --volume /parsecfs:/parsecfs
 --volume /dev:/dev
 --volume /var/lib/incus:/var/lib/incus
 --volume /lib/modules:/lib/modules:ro
 ghcr.io/cmspam/incus-docker:latest`
	)
	if _, err := shell.FromString("docker load --input incus-docker.tar.gz").WithDir(i.path).Run(); err != nil {
		return fmt.Errorf("failed to load incus container: %w", err)
	}
	dockerps, err := shell.FromString(dockerPsCMD).Run()

	if err != nil {
		return fmt.Errorf("failed to get docker ps: %w", err)
	}

	if !strings.Contains(dockerps, "incus") {
		if _, err := shell.FromString(dockerRunCMD).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("failed to docker run: %w", err)
		}
		time.Sleep(time.Second * 5)
	}
	log.Println("incus container runned")
	return nil
}

func (i *Install) initIncus() error {
	var (
		// configCMD = `docker exec -it incus bash -c "cat /var/lib/incus/config.yaml | incus admin init --preseed"`
		certCMD         = "docker exec incus incus config trust add local"
		remoteAddCMD    = "incus remote add incus https://127.0.0.1:8443 --accept-certificate --token %s"
		remoteListCMD   = "incus remote list --columns u --format compact"
		remoteSwitchCMD = "incus remote switch incus"
	)

	if err := fs.WriteFile("/var/lib/incus/config.yaml", []byte(config)); err != nil {
		return fmt.Errorf("failed to create incus config: %w", err)
	}
	if _, err := shell.New("docker", []string{"exec", "incus", "bash", "-c", `cat /var/lib/incus/config.yaml | incus admin init --preseed`}...).Run(); err != nil {
		return fmt.Errorf("failed to load incus config: %w", err)
	}

	certout, err := shell.FromString(certCMD).Run()
	if err != nil {
		return fmt.Errorf("failed to create local cert: %w", err)
	}
	cert := strings.ReplaceAll(certout, certFind, "")

	remoteout, err := shell.FromString(remoteListCMD).Run()
	if err != nil {
		return fmt.Errorf("failed to get remote incus list: %w", err)
	}
	if !strings.Contains(remoteout, remoteFind) {
		if _, err := shell.FromString(fmt.Sprintf(remoteAddCMD, cert)).Run(); err != nil {
			return fmt.Errorf("failed to add local connect: %w", err)
		}
	}
	if _, err := shell.FromString(remoteSwitchCMD).Run(); err != nil {
		return fmt.Errorf("failed to switch on local incus: %w", err)
	}

	log.Println("incus inited")
	log.Printf("save your cert\nuser: local\ncert: %s", cert)
	return nil
}

func (i *Install) loadImages() error {
	var (
		imagesListCMD = "incus image list --columns l --format compact"
		loadAlceCMD   = "incus image import alce-incus-lxc-image.tar.gz --alias alce"
		loadAlseCMD   = "incus image import alse-incus-lxc-image.tar.gz --alias alse"
	)
	imagesout, err := shell.FromString(imagesListCMD).Run()
	if err != nil {
		return fmt.Errorf("failed to get images list: %w", err)
	}
	if !strings.Contains(imagesout, "alce") {
		if _, err := shell.FromString(loadAlceCMD).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("failed to load alce image: %w", err)
		}
	}
	if !strings.Contains(imagesout, "alse") {
		if _, err := shell.FromString(loadAlseCMD).WithDir(i.path).Run(); err != nil {
			return fmt.Errorf("failed to load alse image: %w", err)
		}
	}
	log.Println("astra images loaded")
	return nil
}
