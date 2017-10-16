#!/bin/bash
#用户在访问www.joy.com 网站的news 目录时，我这个目录还在建设中，那么想要实现的就是用户访问该目录下任何一个文件，返回的都是首页文件，给用户以提示

#anzhuangruanjian_nginx
sh nginx_install.sh

#chuangjianmulu
mkdir /usr/share/nginx/joy.com -p
mkdir /usr/share/nginx/joy.com/news -p

#peizhifabuxinxi
echo joy > /usr/share/nginx/joy.com/index.html
echo building > /usr/share/nginx/joy.com/news/index.html

#
touch /usr/share/nginx/joy.com/news/new1.html
touch /usr/share/nginx/joy.com/news/new2.html

#peizhixunizhuji
cat > /etc/nginx/conf.d/www.joy.com.conf << EOT
server {
listen 80;
server_name www.joy.com;
#charset koi8-r;
#access_log /var/log/nginx/log/host.access.log main;
root /usr/share/nginx/joy.com;
index index.html index.htm;
location ~* /news/ {
rewrite ^/news/.* /news/index.html break;
 }
}
EOT


#qidongfuwu
service nginx restart &>/dev/null
netstat -tunpl |grep :80 &>/dev/null && echo "nginx is ok!"



