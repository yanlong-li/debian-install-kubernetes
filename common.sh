#!/bin/bash
# 替换清华大学mirror
cat <<EOF | tee /etc/apt/sources.list
# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

deb http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware

deb http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware
# deb-src http://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

# deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
# # deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
EOF

apt update
apt install -y curl gpg

containerdVersion=1.7.7
# 这四个文件要走 github 比较慢，可以换成其它源
curl -o containerd-${containerdVersion}-linux-amd64.tar.gz https://ghproxy.com/https://github.com/containerd/containerd/releases/download/v{containerdVersion}/containerd-{containerdVersion}-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-${containerdVersion}-linux-amd64.tar.gz

mkdir /usr/local/lib/systemd/system -p
curl -o /usr/local/lib/systemd/system/containerd.service https://ghproxy.com/https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

# runc
runcVersion=1.1.9
curl -o runc.amd64 https://ghproxy.com/https://github.com/opencontainers/runc/releases/download/v${runcVersion}/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

# cni
cniVersion=1.3.0
curl -o cni-plugins-linux-amd64-v${cniVersion}.tgz https://ghproxy.com/https://github.com/containernetworking/plugins/releases/download/v${cniVersion}/cni-plugins-linux-amd64-v${cniVersion}.tgz
mkdir /opt/cni/bin -p
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${cniVersion}.tgz


mkdir /etc/containerd/
containerd config default | tee /etc/containerd/config.toml

sed -i 's@registry.k8s.io/pause:3.8@registry.aliyuncs.com/google_containers/pause:3.9@' /etc/containerd/config.toml
sed -i 's@SystemdCgroup = false@SystemdCgroup = true@' /etc/containerd/config.toml
systemctl restart containerd

curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://mirrors.tuna.tsinghua.edu.cn/kubernetes/apt kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl


cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
