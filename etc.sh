#!/bin/bash

if [ ! -d "/home/www/default" ]; then
	mkdir -p /home/www/default
	chown -R www:www /home/www/default
	chmod -R 644 /home/www/default
fi
# adminer.php
curl https://github.com/vrana/adminer/releases/download/v4.6.2/adminer-4.6.2.php > /home/www/default/adminer.php
cp -rvf ./www/default/* /home/www/default/


echo
read -p "Please input nginx authorized_user pwd: " auth_user_pass
[ -z "$auth_user_pass" ] && auth_user_pass="no"

if [ "$auth_user_pass" != "no" ]; then
	pwd=`openssl passwd -crypt $auth_user_pass`
	printf "u1:$pwd\n" >>/home/etc/nginx/authorized_user.txt
fi