#!/bin/bash

install_pgsql(){
	yum -y install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-6-x86_64/pgdg-centos10-10-2.noarch.rpm
	yum -y install postgresql10 postgresql10-server postgresql10-contrib
	service postgresql-10 initdb --locale=zh_CN.UTF-8
	service postgresql-10 on
	service postgresql-10 start

	yum -y install pgbouncer
	service pgbouncer on
	service pgbouncer start

	touch /var/lib/pgsql/.psql_history
	chown postgres:postgres /var/lib/pgsql/.psql_history
	chmod 666 /var/lib/pgsql/.psql_history

	ln -sf /var/lib/pgsql /home/db/pgsql
	ln -sf /var/lib/pgsql/10/pgstartup.log /home/log/pgsql_10_pgstartup.log

	ln -sf /etc/pgbouncer /home/etc/pgbouncer
	ln -sf /var/log/pgbouncer/pgbouncer.log /home/log/pgbouncer.log

	echo '--------------------------------------------------'
	echo '用  su - postgres -c psql  修改密码'
	echo "ALTER USER postgres WITH PASSWORD 'postgres'"
}

install_pgsql