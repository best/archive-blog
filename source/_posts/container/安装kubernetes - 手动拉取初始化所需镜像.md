---
title: 安装kubernetes之手动拉取初始化所需镜像
date: 2018-12-07 23:37:07
updated: 2018-12-07 23:37:07
tags:
- kubernetes
categories:
- container
---
安装kubernetes后进行初始化的过程中需要使用一些gcr.io上的镜像，然而在国内安装Kubernetes，因为k8s.gcr.io在谷歌的服务器上，会因为镜像拉取不成功导致kubernetes初始化失败，所以下面给出一个手动拉取kubernetes镜像的方式。



## 拉取流程

### 寻找安全的国内google_containers镜像仓库

因为镜像拉取会带来很多安全隐患，因此我们选择国内的镜像仓库要选择较为安全的节点，经过多番查找，我找到了阿里云的官方google_containers镜像仓库，使用阿里云官方的镜像仓库还是很放心的~

阿里云google_containers镜像： `registry.cn-hangzhou.aliyuncs.com/google_containers`

当然如果有其他安全的google_containers国内镜像仓库地址，也可以使用其他的地址~



### 查看当前kubernetes所需镜像列表

手动拉取镜像首先需要知道当前版本Kubernetes所需的镜像有哪些对应的标签是什么，拉取对应版本的镜像下来才能让后面的Kubernetes正常启动。

经过查阅官方文档，在kubernetes.io上面找到了一个获取镜像列表的方式，这个方式本来是用于离线初始化kubernetes的，这里我们用来获取当前版本的kubernetes所需的镜像列表。

在安装了kubernetes的服务器上执行`kubeadm config images list`命令，就能获取当前版本kubernetes所需的镜像列表

命令：`kubeadm config images list`

文档地址：`https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/#running-kubeadm-without-an-internet-connection`

v1.13.0版本kubernetes执行`kubeadm config images list`后的镜像列表：

```bash
k8s.gcr.io/kube-apiserver:v1.13.0
k8s.gcr.io/kube-controller-manager:v1.13.0
k8s.gcr.io/kube-scheduler:v1.13.0
k8s.gcr.io/kube-proxy:v1.13.0
k8s.gcr.io/pause:3.1
k8s.gcr.io/etcd:3.2.24
k8s.gcr.io/coredns:1.2.6
```



### 从阿里云镜像仓库中拉取镜像

获取到镜像列表后，就能从google_containers镜像仓库中拉取镜像了

以v1.13.0版本为例，获取到镜像列表后，从阿里云拉取镜像的命令如下

```bash
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.13.0
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.2.24
docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.2.6
```



### 将镜像重新打标签

镜像全部拉取成功后，我们可以用`docker images | grep google_containers`查看拉取后的镜像列表，然后将其重新标记为`k8s.gcr.io`下

以v1.13.0拉取后的镜像列表为

```bash
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.13.0
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.13.0
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.13.0
registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.13.0
registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1
registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.2.24
registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.2.6
```

对其依次执行`docker tag`命令，将其标记为`k8s.gcr.io`下

```bash
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-apiserver:v1.13.0 k8s.gcr.io/kube-apiserver:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-controller-manager:v1.13.0 k8s.gcr.io/kube-controller-manager:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-scheduler:v1.13.0 k8s.gcr.io/kube-scheduler:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/kube-proxy:v1.13.0 k8s.gcr.io/kube-proxy:v1.13.0
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.1 k8s.gcr.io/pause:3.1
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/etcd:3.2.24 k8s.gcr.io/etcd:3.2.24
docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/coredns:1.2.6 k8s.gcr.io/coredns:1.2.6
```

至此，我们就完成kubernetes初始化所需镜像的手动拉取了。



## 流程总结

1. 查看kubernetes初始化所需镜像

   `kubeadm config images list`

2. 从国内镜像仓库拉取镜像

   `docker pull` + 镜像

3. 将镜像重新打标签为k8s.gcr.io

   `docker tag` + 拉取下的镜像 + k8s.gcr.io/镜像 

通过上面三个步骤，就能成功手动拉取镜像到kubernetes安装服务器了



## 最后说明

拉取kubernetes初始化所需镜像的方式还有很多种，本次就先说一个最简单的拉取镜像的方式，其他方式比如通过github拉取镜像并推送到docker hub，在服务器上通过代理拉取镜像，在本机通过代理拉取镜像并推送到docker Hub或私有镜像仓库等，大家可以自行研究~

后面若有时间，我会写一个自动从国内镜像服务器拉取kubernetes初始化所需镜像的脚本~





---

本文写在2018年12月7日 - 戊戌年甲子月癸酉日 - 大雪

张昊辰 - XThundering