#!/bin/bash

sudo apt-get update
sudo apt-get install apache2 libapache2-mod-fastcgi

# enable php-fpm
sudo cp \
    ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf.default \
    ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf

sudo a2enmod rewrite actions fastcgi alias
mysqladmin -u root create sulu

echo "cgi.fix_pathinfo = 1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini

~/.phpenv/versions/$(phpenv version-name)/sbin/php-fpm

# configure apache virtual hosts
sudo cp -f \
    tests/travis-ci-apache \
    /etc/apache2/sites-available/default

sudo sed -e "s?%TRAVIS_BUILD_DIR%?$(pwd)?g" --in-place /etc/apache2/sites-available/default
sudo service apache2 restart

mkdir -p $LOGS_DIR
composer selfupdate
composer install --no-interaction
cp app/Resources/webspaces/sulu.io.xml.dist app/Resources/webspaces/sulu.io.xml
cp app/Resources/pages/overview.xml.dist app/Resources/pages/overview.xml
cp app/Resources/pages/default.xml.dist app/Resources/pages/default.xml

php app/console sulu:build dev --no-interaction

./tests/sauce/connect_setup.sh
./tests/sauce/connect_block.sh
