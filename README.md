# Debian install kubernetes script
> Debian version 12

适用于 Debian 12 的官网版本（仅安装 SSH Service 和基础系统镜像），脚本不包含 swap 的关闭，默认为您已手动关闭（并且是永久关闭，否则重启服务器后可能导致 k8s 服务无法启动，临时关闭使用 ` swapoff -a` ）。

不同云厂商的 Debian 环境可能不一样，不一定适用。

* 不对使用该脚本产生的问题负责！！！请仅在开发、学习、测试环境使用！！！
* 如果需要更换 apt 镜像，请运行 apt-mirror.sh 或手动更换。

## command


```shell
git clone https://github.com/yanlong-li/debian-install-kubernetes && cd debian-install-kubernetes
```

### 安装

```shell
./install.sh
```



## FAQ

### 如何关闭 swap
推荐本地安装时就不要开启 swap，一劳永逸

临时关闭：
```shell
swapoff -a
```

永久关闭：修改 `/etc/fstab` 中的 swap 行，最前面添加 # 号注释。

ps: sysinit.target 可能依旧依赖，可禁用依赖
```shell
systemctl edit sysinit.target --full
```

将配置内容由：

    Wants=local-fs.target swap.target
    After=local-fs.target swap.target

改为：

    Wants=local-fs.target
    After=local-fs.target
