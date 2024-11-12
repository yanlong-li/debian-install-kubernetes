#!/bin/bash


read -p "请输入 pod-network-cidr (默认: 10.244.0.0/16): " pod_network_cidr
pod_network_cidr=${pod_network_cidr:-"10.244.0.0/16"}  # 如果未输入则使用“用户”作为默认值

read -p "请输入 apiserver-advertise-address (可选): "apiserver_advertise_address
apiserver_advertise_address=${apiserver_advertise_address:-""}  # 如果未输入则使用“用户”作为默认值

kubeadm init --image-repository registry.aliyuncs.com/google_containers --pod-network-cidr=${pod_network_cidr} --apiserver-advertise-address=${apiserver_advertise_address} --v=5

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

calicoVersion=3.29.0

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${calicoVersion}/manifests/tigera-operator.yaml

curl -o custom-resources.yaml https://raw.githubusercontent.com/projectcalico/calico/v${calicoVersion}/manifests/custom-resources.yaml

sed -i 's@192.168.0.0/16@10.244.0.0/16@' custom-resources.yaml

kubectl create -f custom-resources.yaml

watch "kubectl get pods -n calico-system && kubectl get nodes"
