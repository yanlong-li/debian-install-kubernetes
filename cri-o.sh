#!/bin/bash
apt update
apt install curl gnupg2 -y

coreVersion=1.31
curl -fsSL https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v${coreVersion}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/core:/stable:/v${coreVersion}/deb/ /
deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.ustc.edu.cn/kubernetes/addons:/cri-o:/stable:/v${coreVersion}/deb/ /
EOF


apt update && apt install -y kubelet kubeadm kubectl cri-o
apt-mark hold kubelet kubeadm kubectl cri-o

crio config default | tee /etc/crio/crio.conf

sed -i 's@registry.k8s.io@registry.aliyuncs.com/google_containers@' /etc/crio/crio.conf
sed -i 's@# pause_image@pause_image@' /etc/crio/crio.conf
sed -i 's@# cgroup_manager@cgroup_manager@' /etc/crio/crio.conf

systemctl enable crio && systemctl restart crio