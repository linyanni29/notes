#!/bin/bash
#挂载U盘
mkdir /mnt/usb -p
mount /dev/sda1  /mnt/usb/

#安装文件系统
yum -y install filesystem --installroot=/mnt/usb/

#安装应用程序与bash shell
yum -y install bash coreutils findutils grep vim-enhanced rpm yum passwd net-tools util-linux lvm2 openssh-clients bind-utils --installroot=/mnt/usb/

#安装内核
cp -a /boot/vmlinuz-2.6.32-431.el6.x86_64 /mnt/usb/boot/
cp -a /boot/initramfs-2.6.32-431.el6.x86_64.img /mnt/usb/boot/
cp -arv /lib/modules/2.6.32-431.el6.x86_64/ /mnt/usb/lib/modules/

#安装grub软件
rpm -ivh http://172.25.254.254/content/rhel6.5/x86_64/dvd/Packages/grub-0.97-83.el6.x86_64.rpm --root=/mnt/usb/ --nodeps --force
grub-install  --root-directory=/mnt/usb/ /dev/sda --recheck

#配置 grub.conf
cp /boot/grub/grub.conf  /mnt/usb/boot/grub/
cat > /mnt/usb/boot/grub/grub.conf <<END
default=0
timeout=5
splashimage=/boot/grub/splash.xpm.gz
hiddenmenu
title My usb system from hugo
        root (hd0,0)
        kernel /boot/vmlinuz-2.6.32-431.el6.x86_64 ro root=UUID=c421b90d-5393-4104-aa7d-fb3cee92744a selinux=0 
        initrd /boot/initramfs-2.6.32-431.el6.x86_64.im
END

cp /boot/grub/splash.xpm.gz /mnt/usb/boot/grub/

#完善配置文件
cp /etc/skel/.bash* /mnt/usb/root/

#配置主机名与网卡
cat > /mnt/usb/etc/sysconfig/network <<ABC
NETWORKING=yes
HOSTNAME=myusb.hugo.org
ABC

cp /etc/sysconfig/network-scripts/ifcfg-eth0 /mnt/usb/etc/sysconfig/network-scripts/

cat > /mnt/usb/etc/sysconfig/network-scripts/ifcfg-eth0 <<DEF
DEVICE="eth0"
BOOTPROTO="static"
ONBOOT="yes"
IPADDR=192.168.0.118
NETMASK=255.255.255.0
GATEWAY=192.168.0.254
DNS1=8.8.8.8
DEF

#定义fstab
cat > /mnt/usb/etc/fstab <<BCD
UUID="c421b90d-5393-4104-aa7d-fb3cee92744a" /  ext4 defaults 0 0
proc                    /proc                   proc    defaults        0 0
sysfs                   /sys                    sysfs   defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
BCD

#设置密码
sed -i 's/^root.*/root:$1$yANhV\/$51rp8k6Clhjb2aycQHBB0.:15937:0:99999:7:::/' /mnt/usb/etc/shadow

#卸载U盘
umount /mnt/usb/



























