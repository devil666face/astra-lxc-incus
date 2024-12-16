# Use the official Debian Bookworm base image
# FROM debian:bookworm-slim
FROM registry.astralinux.ru/library/astra/ubi18:latest

RUN echo "#!/bin/bash" > /sbin/systemctl && \
    echo "exit 0" >> /sbin/systemctl && \
    chmod +x /sbin/systemctl && \
    echo "deb https://download.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/1/main-repository 1.8_x86-64 main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb https://download.astralinux.ru/astra/stable/1.8_x86-64/repository-main/ 1.8_x86-64 main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://download.astralinux.ru/astra/stable/1.8_x86-64/repository-extended/ 1.8_x86-64 main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://download.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/uu/1/extended-repository/ 1.8_x86-64 main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb [trusted=yes] http://deb.debian.org/debian bookworm main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb [trusted=yes] http://deb.debian.org/debian bookworm-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb [trusted=yes] http://security.debian.org/debian-security bookworm-security main contrib non-free" >> /etc/apt/sources.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y curl ca-certificates debian-archive-keyring

RUN apt-get install --no-install-recommends -y fuse nftables ebtables arptables iproute2 thin-provisioning-tools openvswitch-switch btrfs-progs lvm2 udev iptables kmod && \
    apt-get install --no-install-recommends --no-install-suggests -y zfsutils-linux

RUN mkdir -p /etc/apt/keyrings/ && \
    curl -fsSL https://pkgs.zabbly.com/key.asc -o /etc/apt/keyrings/zabbly.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/zabbly.asc] https://pkgs.zabbly.com/incus/stable bookworm main" > /etc/apt/sources.list.d/zabbly-incus-stable.list && \
    apt-get update && \
    apt-get install --no-install-recommends -y incus incus-ui-canonical && \
    apt-get remove -y curl && \
    apt autoremove -y && \
    apt-get clean
#    update-alternatives --set iptables /usr/sbin/iptables-legacy && \
#    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy && \
#    update-alternatives --set arptables /usr/sbin/arptables-legacy && \
#    update-alternatives --set ebtables /usr/sbin/ebtables-legacy && \
RUN echo '#!/bin/bash' > /start.sh && \
    echo 'trap "cleanup; exit" SIGTERM' >> /start.sh && \
    echo 'cleanup() {' >> /start.sh && \
    echo '  echo "Stopping incusd..."' >> /start.sh && \
    echo '  incus admin shutdown' >> /start.sh && \
    echo '  pkill -TERM incusd' >> /start.sh && \
    echo '  echo "Stopped incusd."' >> /start.sh && \
    echo '  echo "Stopping lxcfs..."' >> /start.sh && \
    echo '  pkill -TERM lxcfs' >> /start.sh && \
    echo '  fusermount -u /var/lib/incus-lxcfs' >> /start.sh && \
    echo '  echo "Stopped lxcfs."' >> /start.sh && \
    echo ' CHILD_PIDS=$(pgrep -P $$)' >> /start.sh && \
    echo ' if [ -n "$CHILD_PIDS" ]; then' >> /start.sh && \
    echo '   pkill -TERM -P $$' >> /start.sh && \
    echo '   echo "Stopped child processes with PIDs: $CHILD_PIDS"' >> /start.sh && \
    echo ' else' >> /start.sh && \
    echo '   echo "No child processes found."' >> /start.sh && \
    echo ' fi' >> /start.sh && \
    echo '}' >> /start.sh && \
    echo 'export PATH="/opt/incus/bin/:${PATH}"' >> /start.sh && \
    echo 'export INCUS_EDK2_PATH="/opt/incus/share/qemu/"' >> /start.sh && \
    echo 'export LD_LIBRARY_PATH="/opt/incus/lib/"' >> /start.sh && \
    echo 'export INCUS_LXC_TEMPLATE_CONFIG="/opt/incus/share/lxc/config/"' >> /start.sh && \
    echo 'export INCUS_DOCUMENTATION="/opt/incus/doc/"' >> /start.sh && \
    echo 'export INCUS_LXC_HOOK="/opt/incus/share/lxc/hooks/"' >> /start.sh && \
    echo 'export INCUS_AGENT_PATH="/opt/incus/agent/"' >> /start.sh && \
    echo 'export INCUS_UI="/opt/incus/ui/"' >> /start.sh && \
    echo 'if [ "$SETIPTABLES" = "true" ]; then' >> /start.sh && \
    echo '  if ! iptables-legacy -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo '    iptables-legacy -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo '  fi' >> /start.sh && \
    echo '  if ! ip6tables-legacy -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo '    ip6tables-legacy -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo '  fi' >> /start.sh && \
    echo '  if ! iptables -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo '    iptables -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo '  fi' >> /start.sh && \
    echo '  if ! ip6tables -C DOCKER-USER -j ACCEPT &>/dev/null; then' >> /start.sh && \
    echo '    ip6tables -I DOCKER-USER -j ACCEPT' >> /start.sh && \
    echo '  fi' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '  mkdir -p /var/lib/incus-lxcfs' >> /start.sh && \
    echo '  /opt/incus/bin/lxcfs /var/lib/incus-lxcfs --enable-loadavg --enable-cfs &' >> /start.sh && \
    echo '/usr/lib/systemd/systemd-udevd &' >> /start.sh && \
    echo 'UDEVD_PID=$!' >> /start.sh && \
    echo '/opt/incus/bin/incusd &' >> /start.sh && \
    echo 'sleep infinity' >> /start.sh && \    
    chmod +x /start.sh

# Set environment variables
#ENV PATH="/opt/incus/bin/:${PATH}"
#ENV INCUS_EDK2_PATH="/opt/incus/share/qemu/"
#ENV LD_LIBRARY_PATH="/opt/incus/lib/"
#ENV INCUS_LXC_TEMPLATE_CONFIG="/opt/incus/share/lxc/config/"
#ENV INCUS_DOCUMENTATION="/opt/incus/doc/"
#ENV INCUS_LXC_HOOK="/opt/incus/share/lxc/hooks/"
#ENV INCUS_AGENT_PATH="/opt/incus/agent/"
#ENV INCUS_UI="/opt/incus/ui/"

# Run the incusd binary
CMD ["/start.sh"]

