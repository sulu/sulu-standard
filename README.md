sulu
====

## Installation

#### Clone this repository

```
git clone git@github.com:sulu-cmf/sulu-standard.git
cd sulu-standard
```

#### Checkout the develop-branch

```
git checkout develop
```

#### Install all the dependencies with composer

```
composer install
```
Answer the following questions to meet the installation of your system. Just use the standard value for the `jms_serializer.cache_naming_strategy.class`.

#### Clear the caches and set the appropriate permissions

##### Mac OSX
```
rm -rf app/admin/cache/*
rm -rf app/admin/logs/*
rm -rf app/website/cache/*
rm -rf app/website/logs/*
APACHEUSER=`ps aux | grep -E '[a]pache|[h]ttpd' | grep -v root | head -1 | cut -d\  -f1`
sudo chmod +a "$APACHEUSER allow delete,write,append,file_inherit,directory_inherit" app/admin/cache app/admin/logs app/website/cache app/website/logs
sudo chmod +a "`whoami` allow delete,write,append,file_inherit,directory_inherit" app/admin/cache app/admin/logs app/website/cache app/website/logs
```

##### Ubuntu
```
rm -rf app/admin/cache/*
rm -rf app/admin/logs/*
rm -rf app/website/cache/*
rm -rf app/website/logs/*
sudo setfacl -R -m u:www-data:rwx -m u:`whoami`:rwx app/admin/cache app/admin/logs app/website/cache app/website/logs
sudo setfacl -dR -m u:www-data:rwx -m u:`whoami`:rwx app/admin/cache app/admin/logs app/website/cache app/website/logs
```

#### Create database and schema
```
app/console doctrine:database:create
app/console doctrine:schema:create
```

#### Load database default values
```
app/console doctrine:fixtures:load
```
Answer the upcoming question with `Y`, to purge the entire database.

#### Insert a new user
```
app/console sulu:security:user:create
```
Follow the instruction to create a new user

## Configuration
Sulu requires an installation of an apache webserver with PHP (>=5.4) and a mysql database. 

Use the following template for your vhost-configuration
```
<VirtualHost *:80>
    DocumentRoot "[path-to-your-workspace]/sulu-standard/web"
    ServerName sulu.lo
    <Directory "[path-to-your-workspace]/sulu-standard/web">
        Options Indexes FollowSymlinks
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
```

Of course you also have to make sure that your webserver user has permission to access your installation folder.
Don't forget to include `sulu.lo` in your hosts-file, if you want to use Sulu on a local machine.
