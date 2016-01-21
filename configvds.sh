#!/bin/bash
locale-gen ru_RU
locale-gen ru_RU.UTF-8
dpkg-reconfigure locales
update-locale LANG=ru_RU.UTF-8
apt-get update
apt-get upgrade
apt-get install gcc memcached python-profiler python-setuptools libpq-dev git-core python-dev supervisor nginx postgresql nano emacs libtiff5-dev sudo
easy_install virtualenv
echo "Введите имя пользователя"
read user
adduser $user
mkdir /home/$user/www
cd /home/$user
echo "$user    ALL=(ALL:ALL) ALL" >> /etc/sudoers
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = 'localhost'/g" /etc/postgresql/9.3/main/postgresql.conf
echo "Пароль для базы данных"
sudo -u postgres createuser $user -P -s
sudo -u postgres createdb $user
echo 'Пользователь $user добавлен в postgresql'