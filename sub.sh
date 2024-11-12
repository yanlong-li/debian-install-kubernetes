#!/bin/bash
# start 这个是子节点独有的
# 这条命令替换成主节点初始化后的内容

echo "请从 Control 节点获取加入命令，格式如下"

echo \033[32mkubeadm join xxxx --token xxxx \
    --discovery-token-ca-cert-hash sha256:xxxx\033[0m
# end 这个是子节点独有的
