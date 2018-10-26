#!/bin/bash

yum install make gcc g++ gcc-c++ libtool autoconf automake imake libxml2-devel expat-devel

cd /root

if [ ! -s coreseek-4.1-beta.tar.gz ]; then
	wget http://files.opstool.com/man/coreseek-4.1-beta.tar.gz
fi
tar zxvf coreseek-4.1-beta.tar.gz
cd coreseek-4.1-beta
cd mmseg-3.2.14
aclocal
libtoolize --force
automake --add-missing
autoconf
autoheader
make clean #此时如有错误可忽略不管
# ./bootstrap
./configure --prefix=/usr/local/coreseek
make
make install
if [ $? -ne 0 ]; then
	exit 1
fi
echo '-----------mmseg 安装成功-----------------'

cd ..
cd csft-4.1
make clean
# 错误修复------------start
# detail see: https://blog.csdn.net/jcjc918/article/details/39032689
sed -i '/&& aclocal \\/a\&& automake --add-missing \\' ./buildconf.sh
sed -i 's/AM_INIT_AUTOMAKE(\[-Wall -Werror foreign\])/AM_INIT_AUTOMAKE([-Wall foreign])/' ./configure.ac
sed -i '/AC_PROG_RANLIB/a\AM_PROG_AR' ./configure.ac
sed -i 's/T val = ExprEval ( this->m_pArg, tMatch );/T val = this->ExprEval ( this->m_pArg, tMatch );/g' ./src/sphinxexpr.cpp
# 错误修复------------end
./buildconf.sh
./configure --prefix=/usr/local/coreseek -without-python --without-unixodbc \
--with-mmseg=/usr/local/coreseek \
--with-mmseg-includes=/usr/local/coreseek/include/mmseg/ \
--with-mmseg-libs=/usr/local/coreseek/lib/ \
--with-mysql
make
make install

if [ $? -ne 0 ]; then
	exit 1
fi

cat >/usr/lib/systemd/system/coreseek.service<<EOF
[Unit]
Description=CoreSeek Searchd
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/home/db/sphinx/log/searchd.pid
ExecStart=/usr/local/coreseek/bin/searchd
ExecReload=/usr/local/coreseek/bin/searchd --stop
ExecStop=/usr/local/coreseek/bin/searchd --stop
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl enable coreseek
systemctl start coreseek

echo '---------mmseg 测试-----------------------'
cd ..
cd testpack
/usr/local/coreseek/bin/indexer -c etc/csft.conf --all