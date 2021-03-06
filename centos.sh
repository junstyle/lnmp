#!/bin/bash

source ./inc/set-ius-repo.sh

yum update -y
yum clean all

yum -y install screen dstat		#date && dstat -tclmdnys 60


RELEASE_RPM=$(rpm -qf /etc/redhat-release)
RELEASE=$(rpm -q --qf '%{VERSION}' ${RELEASE_RPM})


#install remi repo
case ${RELEASE} in
	6*)
		wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
		wget http://rpms.remirepo.net/enterprise/remi-release-6.rpm
		rpm -Uvh remi-release-6.rpm epel-release-latest-6.noarch.rpm
		;;
	7*)
		wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		wget http://rpms.remirepo.net/enterprise/remi-release-7.rpm
		rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
		;;
esac

case ${RELEASE} in
	7*)
		systemctl stop firewalld
		systemctl disable firewalld
		systemctl status firewalld
		yum install -y iptables-services
		systemctl enable iptables
		systemctl start iptables
		systemctl status iptables
		;;
esac

#开放端口
if [ `iptables -L | wc -l` == "8" ]; then
	cat >>/etc/sysconfig/iptables<<eof
# Generated by iptables-save v1.4.21 on Mon Mar 25 04:07:37 2019
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [14760:15404092]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 7639 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
# Completed on Mon Mar 25 04:07:37 2019
eof
else
	iptables -D INPUT 4  #删除input的第3条规则
	iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport 7639 -j ACCEPT	#4为规则号
	iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT	#5为规则号
	iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
	iptables-save > /etc/sysconfig/iptables
fi
service iptables restart

sed -i 's/#Port 22/Port 7639/g' /etc/ssh/sshd_config
# service sshd restart
service sshd restart

#disable selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#define the backspace button can erase the last character typed
cat /etc/profile | grep 'stty erase' | grep -v grep
if [[ $? == 1 ]]; then
	echo 'stty erase ^H' >> /etc/profile
fi
# echo "syntax on" >> /root/.vimrc

cp -rvf ./init/.bashrc /root/.bashrc
cp -rvf ./init/.bash_profile /root/.bash_profile
cp -rvf ./init/.screenrc /root/.screenrc
cp -rvf ./init/.vimrc /root/.vimrc




