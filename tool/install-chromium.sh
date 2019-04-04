#!/bin/bash

cd ~
wget http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/el/updates/6/x86_64/chromium-21.0.1180.89-1.el6.R.x86_64.rpm

yum localinstall chromium-21.0.1180.89-1.el6.R.x86_64.rpm -y

mkdir /root/chromium

sed -i 's/Exec=chromium %u/Exec=chromium %u --sand-box --user-data-dir=\/root\/chromium/g' /usr/share/applications/chromium-browser.desktop