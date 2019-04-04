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

	chkconfig vncserver --level 345 on

	service vncserver start

	sed -i 's/twm &/#twm &/g' ~/.vnc/xstartup
	echo 'gnome-session &' >> ~/.vnc/xstartup

	yum groupinstall "X Window System" -y
	yum install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts -y
	yum groupinstall "fonts" -y

	service vncserver restart
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