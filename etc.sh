#!/bin/bash

if [ ! -d "/home/www/default" ]; then
	mkdir -vp /home/www/default
	chown -R www:www /home/www/default
	chmod -R 644 /home/www/default
fi
# adminer.php
curl -L https://github.com/vrana/adminer/releases/download/v4.6.3/adminer-4.6.3.php > /home/www/default/adminer.php
cp -rvf ./www/default/* /home/www/default/


cp -rvf ./etc/* /etc


echo
read -p "Please input nginx authorized_user pwd: " auth_user_pass
[ -z "$auth_user_pass" ] && auth_user_pass="no"

if [ "$auth_user_pass" != "no" ]; then
	pwd=`openssl passwd -crypt $auth_user_pass`
	printf "u1:$pwd\n" >> /etc/nginx/authorized_user.txt
fi

service php-fpm reload
service nginx reload
service redis reload
service mysqld reload