#!/bin/bash

RELEASE_RPM=$(rpm -qf /etc/redhat-release)
RELEASE=$(rpm -q --qf '%{VERSION}' ${RELEASE_RPM})

install_pgsql(){
	case ${RELEASE} in
		6*)
			yum -y install https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-6-x86_64/pgdg-centos11-11-2.noarch.rpm
			yum -y install postgresql11 postgresql11-server postgresql11-contrib
			# service postgresql-10 initdb --locale=zh_CN.UTF-8
			service postgresql-11 initdb
			chkconfig postgresql-11 on
			service postgresql-11 start

			yum -y install pgbouncer
			chkconfig pgbouncer on
			service pgbouncer start
			;;
		7*)
			yum -y install https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-centos11-11-2.noarch.rpm
			yum -y install postgresql11 postgresql11-server postgresql11-contrib
			/usr/pgsql-11/bin/postgresql-11-setup initdb
			systemctl enable postgresql-11
			systemctl start postgresql-11

			yum -y install pgbouncer
			systemctl enable pgbouncer
			systemctl start pgbouncer
			;;
	esac

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