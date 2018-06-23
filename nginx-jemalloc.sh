#!/bin/bash

version=`nginx -v 2>&1| awk -F"/" '{print $2}'`
config=`nginx -V 2>&1 | awk -F":" '{print $2}' | grep prefix | grep -v grep`
config=${config/--user=nginx --group=nginx/--user=www --group=www}
# config=`echo $config | awk -F"--with-cc-opt=" '{print $1}'`
echo $config
cd ~
if [ ! -s nginx-$version.tar.gz ]; then
	wget http://nginx.org/download/nginx-$version.tar.gz
fi
tar zxvf nginx-$version.tar.gz
cd nginx-$version
./configure $config --with-ld-opt="-ljemalloc"
make && make install

cd ~

rm -rvf nginx-$version*