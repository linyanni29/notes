#!/bin/bash

#read -p "请输入你的发布目录："  dir
#read -p "请输入你要监听的端口："  port

listen_port="80"
my_fabu_dir="/usr/share/nginx/test.com"

iptables -F
setenforce 0

#anzhuangruanjian_nginx
sh nginx_install.sh

#peizhixunizhuji
cat >> /etc/nginx/conf.d/www.abc.com.conf << EOT
server {
    listen       $listen_port;
    server_name  www.test.com;
    charset utf-8;
    access_log  /var/log/nginx/www.abc.com.access.log  main;

    location / {
        root   $my_fabu_dir;
        index  index.html index.htm;
    }
 }
EOT

#创建发布目录
mkdir -p $my_fabu_dir

#检查语法
nginx  -t

#启动服务
systemctl restart nginx &>/dev/null && echo "nginx is ok!"




