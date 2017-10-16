#!/bin/bash

#反向代理服务器serverb
#真实服务器serverc

read -p "please input IP of proxy server:"   ipadd1
read -p "please input IP of real server:"   ipadd2

setenforce 0
iptables -F

#anzhuangruanjian_nginx
sh nginx_install.sh

#jianchawangluo
ping -c 5 172.25.254.250 &>/dev/null || echo "network has problems,please check!"

#anzhuangruanjian_nginx
rpm -ivh ftp://172.25.254.250/notes/project/UP200/UP200_nginx-master/pkg/nginx-1.8.0-1.el7.ngx.x86_64.rpm &>/dev/null && echo "nginx installation successfully!"

#xiugaipeizhiwenjian
#cp /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.bask
cat > /etc/nginx/conf.d/www.proxy.com.conf <<ETO
server {
    listen       80;
    server_name  localhost;
    location / {
        proxy_pass http://$ipadd2;
    }
}
ETO

#qidongfuwu
systemctl restart nginx &>/dev/null
[ $? -ne 0 ] && echo "配置文件有错误，请检查！"


#serverc
#peizhimiyaodenglu
sh ssh_no_passwd.sh $ipadd2

#anzhuangruanjian_http
ssh root@$ipadd2 "yum -y install httpd &>/dev/null && echo "http is install successfully!""

#peizhifabuyemian
ssh root@$ipadd2 "echo serverc1-webserver > /var/www/html/index.html"

#qidongfuwu
ssh root@$ipadd2 "systemctl start httpd &>/dev/null"
ssh root@$ipadd2 "netstat -tunpl | grep :80 &>/dev/null && echo "http is started!""

















