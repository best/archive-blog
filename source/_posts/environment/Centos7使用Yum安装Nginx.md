---
title: Centos7使用Yum安装Nginx
date: 2019-08-12 16:37:26
updated: 2019-08-12 16:37:26
tags:
- nginx
categories:
- environment
---
本文讲述在Centos7环境下使用Yum安装Nginx的方法；介绍Nginx在Linux下的简单优化：如何优化Nginx工作进程数量、优化Nginx工作模式和Nginx连接数上限；介绍在Linux下Vim如何设置Nginx配置文件的语法高亮。



## Nginx安装

### 安装Nginx源

**使用Nginx.org官网源**

```bash
$ rpm -ivh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
```



### 使用Yum安装Nginx

```bash
$ yum install -y nginx
```



### 查看Nginx安装目录

```bash
$ whereis nginx
nginx: /usr/sbin/nginx /usr/lib64/nginx /etc/nginx /usr/share/nginx /usr/share/man/man8/nginx.8.gz /usr/share/man/man3/nginx.3pm.gz
```



### Yum安装后的Nginx默认路径

+ Nginx配置路径：`/etc/nginx/nginx.conf`，`/etc/nginx/conf.d/default.conf`
+ 访问日志：`/var/log/nginx/access.log`
+ 错误日志：`/var/log/nginx/error.log`
+ PID文件位置：`/var/run/nginx.pid`





## Nginx安装后配置

### 配置Nginx开机自启

```bash
$ systemctl enable nginx
```



### Nginx参数优化

#### 优化工作进程数量

```bash
$ vim /etc/nginx/nginx.conf

...
# 启动进程，通常设置成和cpu的数量相等
worker_processes  1;
...
```

修改参数`worker_processes`为逻辑CPU数目，如CPU为2核且开启了超线程，总共有4线程，此处配置为4。

> 可以使用`lscpu`命令，查看CPU(s)值，或使用`cat /proc/cpuinfo | grep 'processor'`命令查看处理器数量



#### 优化工作模式及连接数上限

```bash
$ vim /etc/nginx/nginx.conf

...
# 可被一个工作进程打开的最大文件描述符数量，须小于系统可以打开的最大文件数
worker_rlimit_nofile 65535;

# events模块中包含nginx中所有处理连接的设置，并发响应能力的关键配置
events {
	# 使用非阻塞模型
	# epoll是多路复用IO(I/O Multiplexing)中的一种方式
    # 仅用于linux2.6以上内核，可以大大提高nginx的性能
    use epoll;
    
    # 单个后台worker process进程的最大链接数（最大并发数）
    # 在设置了反向代理的情况下，max_clients = worker_processes * worker_connections / 4
    # 在作为HTTP服务器的情况下，max_clients = worker_processes * worker_connections / 2
    # 对/2或/4的说明：
    # HTTP/1.1协议下，浏览器默认使用两个并发连接
    # 在Nginx作为反向代理服务器的时候，和客户端之间保持一个连接，和后端服务器同时也保持一个连接
    # 因为并发受IO约束，max_clients的值须小于系统可以打开的最大文件数：ulimit -a查看open files值
    # worker_connections值不能超过worker_rlimit_nofile值
    worker_connections  65535;
}
...
```



### Vim设置Nginx配置文件的语法高亮

```bash
$ mkdir -p ~/.vim/syntax
$ wget "http://www.vim.org/scripts/download_script.php?src_id=19394" -O ~/.vim/syntax/nginx.vim
$ echo -e "au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif" >> ~/.vim/filetype.vim
```





## 参考链接

+ Nginx基本配置与参数说明：[https://gist.github.com/JingwenTian/8574997](https://gist.github.com/JingwenTian/8574997)

+ Nginx优化配置及详细注释：[https://www.cnblogs.com/taiyonghai/p/5610112.html](https://www.cnblogs.com/taiyonghai/p/5610112.html)

+ Nginx并发数问题思考：[https://blog.51cto.com/liuqunying/1420556](https://blog.51cto.com/liuqunying/1420556)