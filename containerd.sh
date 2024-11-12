#!/bin/bash
apt update
apt install -y curl gnupg2

containerdVersion=2.0.0
# 这四个文件要走 github 比较慢，可以换成其它源
curl -o containerd-${containerdVersion}-linux-amd64.tar.gz https://github.com/containerd/containerd/releases/download/v{containerdVersion}/containerd-{containerdVersion}-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-${containerdVersion}-linux-amd64.tar.gz

mkdir /usr/local/lib/systemd/system -p
curl -o /usr/local/lib/systemd/system/containerd.service https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

# runc
runcVersion=1.2.1
curl -o runc.amd64 https://github.com/opencontainers/runc/releases/download/v${runcVersion}/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

# cni
cniVersion=1.6.0
curl -o cni-plugins-linux-amd64-v${cniVersion}.tgz https://github.com/containernetworking/plugins/releases/download/v${cniVersion}/cni-plugins-linux-amd64-v${cniVersion}.tgz
mkdir /opt/cni/bin -p
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${cniVersion}.tgz


mkdir /etc/containerd/
containerd config default | tee /etc/containerd/config.toml

sed -i 's@registry.k8s.io@registry.aliyuncs.com/google_containers@' /etc/containerd/config.toml
sed -i 's@SystemdCgroup = false@SystemdCgroup = true@' /etc/containerd/config.toml
systemctl restart containerd


coreVersion=1.31
curl -fsSL https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v${coreVersion}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v${coreVersion}/deb/ /
#deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/addons:/cri-o:/stable:/v${coreVersion}/deb/ /
EOF

apt update
apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
