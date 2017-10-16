#!/bin/bash
#关闭防火墙与selinux
setenforce 0
iptables -F

read -p echo "请输入你的DNS地址："  ipadd

#安装软件
yum -y install bind chroot-bind &>/dev/null && echo "bind chroot-bind安装成功!"

#修改主配置文件
cat > /etc/named.conf <<END
options {
	listen-on port 53 { 127.0.0.1; any; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { localhost; any; };
	recursion no;
	dnssec-enable no;
	dnssec-validation no;
	dnssec-lookaside auto;
	bindkeys-file "/etc/named.iscdlv.key";
	managed-keys-directory "/var/named/dynamic";
	pid-file "/run/named/named.pid";
	session-keyfile "/run/named/session.key";
};
logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};
view  dx {
        match-clients { 172.25.20.11; };
	zone "." IN {
		type hint;
		file "named.ca";
	};
	zone "abc.com" IN {
		type master;
		file "abc.com.dx.zone";	
	};
	include "/etc/named.rfc1912.zones";
};
view  wt {
        match-clients { 172.25.20.12; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "abc.com.wt.zone";
        };
	include "/etc/named.rfc1912.zones";
};
view  other {
        match-clients { any; };
        zone "." IN {
                type hint;
                file "named.ca";
        };
        zone "abc.com" IN {
                type master;
                file "abc.com.other.zone";
        };
        include "/etc/named.rfc1912.zones";
};
include "/etc/named.root.key";
END

#配置A记录文件
cat > /var/named/abc.com.dx.zone <<BCD
\$TTL 1D
@	IN SOA	ns1.abc.com. rname.invalid. (
					10	; serial
					1D	; refresh
					1H	; retry
					1W	; expire
					3H )	; minimum
@	NS	ns1.abc.com.
ns1     A       $ipadd
www	A	192.168.11.1
BCD

cat > /var/named/abc.com.wt.zone <<DCE
\$TTL 1D
@       IN SOA  ns1.abc.com. rname.invalid. (
                                        10      ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns1.abc.com.
ns1     A       $ipadd
www     A       22.21.1.1
DCE

cat > /var/named/abc.com.other.zone <<BBC
\$TTL 1D
@       IN SOA  ns1.abc.com. rname.invalid. (
                                        10      ; serial
                                        1D      ; refresh
                                        1H      ; retry
                                        1W      ; expire
                                        3H )    ; minimum
@       NS      ns1.abc.com.
ns1     A       $ipadd
www     A       1.1.1.1
BBC

#修改权限
chgrp named /var/named/abc.com.*

#检测语法
named-checkconf
named-checkzone  abc.com /var/named/abc.com.dx.zone
named-checkzone  abc.com /var/named/abc.com.wt.zone
named-checkzone  abc.com /var/named/abc.com.other.zone

#启动服务并开机自启动
service named start
chkconfig named on &>/dev/null && echo "DNS配置完成！"




