#!/bin/bash

yum install tigervnc-server -y

RELEASE_RPM=$(rpm -qf /etc/redhat-release)
RELEASE=$(rpm -q --qf '%{VERSION}' ${RELEASE_RPM})

install_on_centos6(){
	cat >>/etc/sysconfig/vncservers<<eof
VNCSERVERS="1:root"
VNCSERVERARGS[1]="-geometry 800x600"
eof

	vncpasswd
	vncserver

	chkconfig vncserver --level 345 on

	sed -i 's/twm &/#twm &/g' ~/.vnc/xstartup
	echo 'gnome-session &' >> ~/.vnc/xstartup

	yum groupinstall "X Window System" -y
	yum install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts -y
	yum groupinstall "fonts" -y
	startx

	service vncserver restart

	#打开端口
	iptables -L | grep ACCEPT | grep 5901 | grep -v grep
	if [[ $? == 1 ]]; then
		iptables -L | grep ACCEPT | grep -v policy | wc -l
		if [[ $? == 0 ]]; then
			iid=`iptables -L | grep ACCEPT | grep -v policy | wc -l`
			iid=$(($iid+1))
			iptables -I INPUT $iid -p tcp -m state --state NEW -m tcp --dport 5901 -j ACCEPT
		else
			iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 5901 -j ACCEPT
		fi
		iptables-save > /etc/sysconfig/iptables
	fi
}

install_on_centos7(){
	echo 'nothing.'
}

case ${RELEASE} in
	6*)
		install_on_centos6
		;;
	7*)
		install_on_centos7
		;;
esac