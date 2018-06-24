#!/bin/bash
yum update
yum clean all

yum -y install screen dstat

sed -i 's/#Port 22/Port 7639/g' /etc/ssh/sshd_config
# service sshd restart

#disable selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#define the backspace button can erase the last character typed
echo 'stty erase ^H' >> /etc/profile
echo "syntax on" >> /root/.vimrc

cp -rvf ./init/.bashrc /root/.bashrc
cp -rvf ./init/.bash_profile /root/.bash_profile
cp -rvf ./init/.screenrc /root/.screenrc
cp -rvf ./init/.vimrc /root/.vimrc

#开放端口
iptables -D INPUT 4  #删除input的第3条规则
iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport 7639 -j ACCEPT	#4为规则号
iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT	#5为规则号
iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
iptables-save > /etc/sysconfig/iptables

service sshd restart