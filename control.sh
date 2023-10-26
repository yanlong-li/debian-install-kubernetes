#!/bin/bash

kubeadm init --image-repository registry.aliyuncs.com/google_containers --pod-network-cidr=10.244.0.0/16 --v=5

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl create -f https://ghproxy.com/https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml

curl -o custom-resources.yaml https://ghproxy.com/https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml

sed -i 's@192.168.0.0/16@10.244.0.0/16@' custom-resources.yaml

kubectl create -f custom-resources.yaml

watch "kubectl get pods -n calico-system && kubectl get nodes"
