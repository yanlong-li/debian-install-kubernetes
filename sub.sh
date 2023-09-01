#!/bin/bash
# start 这个是子节点独有的
# 这条命令替换成主节点初始化后的内容
echo "kubeadm join xxxx --token xxxx \
    --discovery-token-ca-cert-hash sha256:xxxx"
# end 这个是子节点独有的
