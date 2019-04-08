#!/bin/bash

RELEASE_RPM=$(rpm -qf /etc/redhat-release)
RELEASE=$(rpm -q --qf '%{VERSION}' ${RELEASE_RPM})

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

	mkdir -v /home/etc
	mkdir -v /home/log

	case ${RELEASE} in
		6*)
			# yum install http://rpms.remirepo.net/enterprise/remi-release-6.rpm -y
			# yum -y install php73-php-fpm php73-php-cli php73-php-xml php73-php-gd php73-php-mysqlnd php73-php-pdo php73-php-pecl-mcrypt php73-php-mbstring php73-php-json php73-php-pgsql php73-php-opcache php73-php-pecl-redis4 php73-php-devel php73-php-phalcon3

			# rm -rvf /home/etc/php.ini
			# ln -vsf /etc/opt/remi/php73/php.ini /home/etc/php.ini
			# rm -rvf /home/etc/php-fpm.conf
			# ln -vsf /etc/opt/remi/php73/php-fpm.conf /home/etc/php-fpm.conf
			# rm -rvf /home/etc/php-fpm.d
			# ln -vsf /etc/opt/remi/php73/php-fpm.d /home/etc/php-fpm.d
			# rm -rvf /home/etc/php.d
			# ln -vsf /etc/opt/remi/php73/php.d /home/etc/php.d
			# rm -rvf /home/log/php-fpm
			# ln -vsf /var/opt/remi/php73/log/php-fpm /home/log/php-fpm
			# chown www:www /var/opt/remi/php73/log/php-fpm
			# sed -i 's@user = apache@user = www@' /home/etc/php-fpm.d/www.conf
			# sed -i 's@group = apache@group = www@' /home/etc/php-fpm.d/www.conf


			yum -y install php71u-fpm php71u-cli php71u-xml php71u-gd php71u-mysqlnd php71u-pdo php71u-mcrypt php71u-mbstring php71u-json php71u-pgsql php71u-opcache php71u-pecl-redis php71u-devel

			rm -rvf /home/etc/php.ini
			ln -vsf /etc/php.ini /home/etc/php.ini
			rm -rvf /home/etc/php-fpm.conf
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
			;;
		7*)
			# yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
			yum -y install php72u-fpm php72u-cli php72u-xml php72u-gd php72u-mysqlnd php72u-pdo php72u-mcrypt php72u-mbstring php72u-json php72u-pgsql php72u-opcache php72u-pecl-redis php72u-devel

			rm -rvf /home/etc/php.ini
			ln -vsf /etc/php.ini /home/etc/php.ini
			rm -rvf /home/etc/php-fpm.conf
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
			;;
	esac

	start_service php-fpm
}

install_mysql(){
	# yum -y remove mysql*

	case ${RELEASE} in
		6*)
			rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el6-1.noarch.rpm
			;;
		7*)
			rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
			;;
	esac

	yum install mysql-community-server mysql-community-devel -y

	start_service mysqld

	mkdir -v /home/db

	rm -rvf /home/db/mysql
	ln -vsf /var/lib/mysql /home/db/mysql
	ln -vsf /var/log/mysqld.log /home/log/mysqld.log

	touch /var/log/mysqld-slow.log
	chown mysql:mysql /var/log/mysqld-slow.log
	ln -vsf /var/log/mysqld-slow.log /home/log/mysqld-slow.log

	ln -vsf /etc/my.cnf /home/etc/my.cnf

	#更改tmp目录
	mkdir /var/tmp/mysql
	chown mysql:mysql /var/tmp/mysql -R
	chmod 777 -R /var/tmp/mysql -R

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

	chown -v www:www /home/etc/nginx/conf.d
	chmod -v 757 /home/etc/nginx/conf.d

	start_service nginx
}

install_redis(){
	yum -y remove redis*
	case ${RELEASE} in
		6*)
			yum -y install redis32u
			;;
		7*)
			yum -y install redis40u
			;;
	esac

	ln -vsf /etc/redis.conf /home/etc/redis.conf
	rm -rvf /home/log/redis
	ln -vsf /var/log/redis /home/log/redis

	start_service redis
}

install_nodejs(){
	yum -y remove nodejs*
	curl -sL https://rpm.nodesource.com/setup_11.x | bash -
	yum -y install nodejs

	#添加 NODE_PATH 全局变量
	cat /etc/profile | grep 'NODE_PATH=/usr' | grep -v grep
	if [[ $? == 1 ]]; then
		cat >>/etc/profile<<eof

export NODE_PATH=/usr/lib/node_modules
eof
		source /etc/profile
	fi

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

	# io 检测工具
	yum install iotop sysstat -y
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
	nodejs*)
		install_nodejs
		;;
	phalcon*)
		# yum install php73-php-phalcon3 -y
		source ./inc/phalcon.sh
		;;
	*)
		remove_anmp
		opt_server
		install_php
		install_mysql
		install_nginx
		install_redis
		install_nodejs

		# source ./inc/phalcon.sh
		source ./etc.sh
		;;
esac

echo '------------------ all over --------------------------'