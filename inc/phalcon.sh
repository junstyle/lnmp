#!/bin/bash
yum install -y gcc
yum install -y re2c

backdir=`pwd`

cd /root/git

if [ -d "cphalcon" ]; then
	cd cphalcon
	git pull
	cd -
else
	git clone --depth=1 "git://github.com/phalcon/cphalcon.git"
fi

cd cphalcon/build
sudo ./install

cd $backdir