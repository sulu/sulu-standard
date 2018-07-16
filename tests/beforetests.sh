#!/bin/bash

export DISPLAY=:99.0
sh -e /etc/init.d/xvfb start

sudo apt-get update
sudo apt-get install apache2 libapache2-mod-fastcgi

# enable php-fpm
sudo cp \
    ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf.default \
    ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.conf

sudo cp \
    ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.d/www.conf.default \
    ~/.phpenv/versions/$(phpenv version-name)/etc/php-fpm.d/www.conf

sudo a2enmod rewrite actions fastcgi alias

echo "cgi.fix_pathinfo = 1" >> ~/.phpenv/versions/$(phpenv version-name)/etc/php.ini

~/.phpenv/versions/$(phpenv version-name)/sbin/php-fpm

# configure apache virtual hosts
sudo cp -f tests/travis-ci-apache /etc/apache2/sites-available/default

sudo sed -e "s?%TRAVIS_BUILD_DIR%?$(pwd)?g" --in-place /etc/apache2/sites-available/default
sudo service apache2 restart

mkdir -p $LOGS_DIR
composer selfupdate

# FIXME hack for prefer-lowest bug: https://github.com/composer/composer/issues/7161
if [[ $COMPOSER_FLAGS == *"--prefer-lowest"* ]]; then composer install; fi

composer update $COMPOSER_FLAGS
cp app/Resources/webspaces/sulu.io.xml.dist app/Resources/webspaces/sulu.io.xml
cp app/Resources/pages/overview.xml.dist app/Resources/pages/overview.xml
cp app/Resources/pages/default.xml.dist app/Resources/pages/default.xml

php app/console sulu:build dev --no-interaction

wget http://selenium-release.storage.googleapis.com/2.52/selenium-server-standalone-2.52.0.jar
java -jar selenium-server-standalone-2.52.0.jar -browserSessionReuse -singleWindow 2> /dev/null &
