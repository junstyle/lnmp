#!/bin/bash

remove_anmp(){
	rpm -qa|grep httpd
    rpm -e httpd httpd-tools
    rpm -qa|grep mysql
    rpm -e mysql mysql-libs
    rpm -qa|grep php
    rpm -e php-mysql php-cli php-gd php-common php

    yum -y remove httpd*
	yum -y remove nginx*
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

	yum -y install php72u-fpm php72u-cli php72u-xml php72u-gd php72u-mysqlnd php72u-pdo php72u-mcrypt php72u-mbstring php72u-json php72u-pgsql php72u-opcache php72u-pecl-redis php72u-devel

	mkdir -v /home/etc
	mkdir -v /home/log

	ln -vsf /etc/php.ini /home/etc/php.ini
	ln -vsf /etc/php-fpm.conf /home/etc/php-fpm.conf
	rm -rvf /home/etc/php-fpm.d
	ln -vsf /etc/php-fpm.d /home/etc/php-fpm.d
	rm -rvf /home/etc/php.d
	ln -vsf /etc/php.d /home/etc/php.d
	rm -rvf /home/log/php-fpm
	ln -vsf /var/log/php-fpm /home/log/php-fpm
	chown www:www /var/log/php-fpm
	sed -i 's@user = php-fpm@user = www@' /etc/php-fpm.d/www.conf
	sed -i 's@group = php-fpm@group = www@' /etc/php-fpm.d/www.conf

	start_service php-fpm
}

install_mysql(){
	# yum -y remove mysql*
	rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm

	yum install mysql-community-server -y

	start_service mysqld

	mkdir -v /home/db

	rm -rvf /home/db/mysql
	ln -vsf /var/lib/mysql /home/db/mysql
	ln -vsf /var/log/mysqld.log /home/log/mysqld.log

	touch /var/log/mysqld-slow.log
	chown mysql:mysql /var/log/mysqld-slow.log
	ln -vsf /var/log/mysqld-slow.log /home/log/mysqld-slow.log

	# sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' /usr/bin/mysqld_safe

	# show temp pwd
	grep "password" /var/log/mysqld.log

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
	ln -vsf /etc/nginx /home/etc/nginx
	rm -rvf /home/log/nginx
	ln -vsf /var/log/nginx /home/log/nginx

	sed -i 's/user  nginx;/user  www;/g' /etc/nginx/nginx.conf

	start_service nginx
}

install_redis(){
	yum -y install redis32u

	ln -vsf /etc/redis.conf /home/etc/redis.conf
	rm -rvf /home/log/redis
	ln -vsf /var/log/redis /home/log/redis

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


echo
read -p "Please input which do you want to install: " which_install
[ -z "$which_install" ] && which_install="all"

case ${which_install} in
	remove_anmp*)
		remove_anmp
		;;
	opt_server*)
		opt_server
		;;
	php*)
		install_php
		;;
	mysql*)
		install_mysql
		;;
	nginx*)
		install_nginx
		;;
	redis*)
		install_redis
		;;
	phalcon*)
		source ./inc/phalcon.sh
		;;
	*)
		remove_anmp
		opt_server
		install_php
		install_mysql
		install_nginx
		install_redis

		source ./inc/phalcon.sh
		source ./etc.sh
		;;
esac

echo '------------------ all over --------------------------'