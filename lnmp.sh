#!/bin/bash

remove_anmp(){
	rpm -qa|grep httpd
    rpm -e httpd httpd-tools
    rpm -qa|grep mysql
    rpm -e mysql mysql-libs
    rpm -qa|grep php
    rpm -e php-mysql php-cli php-gd php-common php

    yum -y remove httpd*
    yum -y remove mysql-server mysql mysql-libs
    yum -y remove php*
    yum -y remove mariadb*
    yum clean all
}

start_service(){
	RELEASE_RPM=$(rpm -qf /etc/redhat-release)
	RELEASE=$(rpm -q --qf '%{VERSION}' ${RELEASE_RPM})

	case ${RELEASE} in
		6*)
			chkconfig $1 on
			service $1 restart
			;;
		7*)
			systemctl enable $1
			systemctl restart $1
			;;
	esac
}

install_php(){
    groupadd www
    useradd -s /sbin/nologin -g www www

	yum -y install php71u-fpm php71u-cli php71u-xml php71u-gd php71u-mysqlnd php71u-pdo php71u-mcrypt php71u-mbstring php71u-json php71u-pgsql php71u-opcache php71u-pecl-redis php71u-devel

	mkdir /home/etc
	mkdir /home/log

	ln -sf /etc/php.ini /home/etc/php.ini
	ln -sf /etc/php-fpm.conf /home/etc/php-fpm.conf
	rm -rvf /home/etc/php-fpm.d
	ln -sf /etc/php-fpm.d /home/etc/php-fpm.d
	rm -rvf /home/etc/php.d
	ln -sf /etc/php.d /home/etc/php.d
	rm -rvf /home/log/php-fpm
	ln -sf /var/log/php-fpm /home/log/php-fpm
	chown www:www /var/log/php-fpm
	sed -i 's@user = php-fpm@user = www@' /etc/php-fpm.d/www.conf
	sed -i 's@group = php-fpm@group = www@' /etc/php-fpm.d/www.conf

	start_service php-fpm
}

install_mysql(){
	# yum -y remove mysql*
	yum -y install mysql57u mysql57u-server mysql57u-devel
	
	start_service mysqld

	mkdir /home/db

	rm -rvf /home/db/mysql
	ln -sf /var/lib/mysql /home/db/mysql
	ln -sf /var/log/mysqld.log /home/log/mysqld.log

	touch /var/log/mysqld-slow.log
	chown mysql:mysql /var/log/mysqld-slow.log
	ln -sf /var/log/mysqld-slow.log /home/log/mysqld-slow.log

	sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/bin/mysqld_safe

	mysql_secure_installation
}

install_nginx(){
	if [ ! -s /etc/yum.repos.d/nginx.repo ]; then
		cat >/etc/yum.repos.d/nginx.repo<<EOF
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=0
enabled=1
EOF
	fi

	yum -y install nginx

    groupadd www
    useradd -s /sbin/nologin -g www www

    rm -rvf /home/etc/nginx
	ln -sf /etc/nginx /home/etc/nginx
	rm -rvf /home/log/nginx
	ln -sf /var/log/nginx /home/log/nginx

	sed -i 's/user  nginx;/user  www;/g' /etc/nginx/nginx.conf

	start_service nginx
}

install_redis(){
	yum -y install redis32u

	ln -sf /etc/redis.conf /home/etc/redis.conf
	rm -rvf /home/log/redis
	ln -sf /var/log/redis /home/log/redis

	start_service redis
}

opt_server(){
	cat /etc/security/limits.conf | grep 'soft nproc 65535' | grep -v grep
	if [[ $? == 1 ]]; then
		cat >>/etc/security/limits.conf<<eof
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
eof
		echo 'add limits params'
	fi

	cat /etc/sysctl.conf | grep 'fs.file-max=65535' | grep -v grep
	if [[ $? == 1 ]]; then
		echo "fs.file-max=65535" >> /etc/sysctl.conf
	fi
}

remove_anmp
opt_server
install_php
install_mysql
install_nginx
install_redis

source ./inc/phalcon.sh
source ./etc.sh


echo '------------------ all over --------------------------'