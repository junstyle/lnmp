#!/bin/bash
yum install -y gcc

backdir=`pwd`

cd /root/git

if [ -d "cphalcon" ]; then
	git pull
else
	git clone --depth=1 "git://github.com/phalcon/cphalcon.git"
fi

cd cphalcon/build
sudo ./install

cd $backdir