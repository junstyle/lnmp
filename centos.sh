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

