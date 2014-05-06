Sulu [![Selenium Test Status](https://saucelabs.com/buildstatus/sulu-cmf)](https://saucelabs.com/u/sulu-cmf) [![](https://travis-ci.org/sulu-cmf/sulu-standard.png)](https://travis-ci.org/sulu-cmf/sulu-standard) [![Scrutinizer Code Quality](https://scrutinizer-ci.com/g/sulu-cmf/sulu-standard/badges/quality-score.png?s=3039e48d6515ea846578ca06f3c5bd5442ad3c5b)](https://scrutinizer-ci.com/g/sulu-cmf/sulu-standard/)
============================================================================================================

Welcome to Sulu - a fully-functional  Content Management Framework (CMF) based on Symfony2.

Licensed under the [MIT License](https://github.com/sulu-cmf/SuluContentBundle/blob/develop/LICENSE).

##Prerequisites

- webserver with PHP (>=5.4) and a mysql database
- [composer](https://getcomposer.org/)
- [grunt-cli](http://gruntjs.com/getting-started)
- [nodejs and npm](http://nodejs.org/)
- [ruby](https://www.ruby-lang.org/en/downloads/) & [compass](http://compass-style.org/install/) (3.2.13)


#### Configuration

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

##### Setup PHPCR Session
Copy the one of the files app/Resources/config/{phpcr_doctrine_dbal.yml.dist} or {phpcr_jackrabbit.yml.dist} to app/Resources/config/phpcr.yml. The config is based on [symfony-cmf sandbox](https://github.com/symfony-cmf/cmf-sandbox). Adjustments to the file contents are optionally.
```
cp app/Resources/config/phpcr_jackrabbit.yml.dist app/Resources/config/phpcr.yml
```
or
```
cp app/Resources/config/phpcr_doctrine_dbal.yml.dist app/Resources/config/phpcr.yml
```

#### Install all the dependencies with composer

```
composer install
```

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

#### Download and install Jackrabbit

Download the jar file into a Folder of your choice.

```
wget http://archive.apache.org/dist/jackrabbit/2.6.3/jackrabbit-standalone-2.6.3.jar
java -jar jackrabbit-standalone-2.6.3.jar
```

#### Create required configuration files
Before you go on with the initialization of the content repository, you have to make sure that all required configuration files exist.

##### Webspaces
Webspaces are configured in the `app/Resources/webspaces`-folder. Copying the existing example should be enough for a local installation:
```
cp app/Resources/webspaces/sulu.io.xml.dist app/Resources/webspaces/sulu.io.xml
```
On an online installation you have to adjust the URLs in this file.

##### Templates
Templates are configured in the `app/Resources/templates`-folder. Copying the existing default template should be enough for a simple page containing a title, a link and a texteditor:

```
cp app/Resources/templates/default.xml.dist app/Resources/templates/default.xml
cp app/Resources/templates/overview.xml.dist app/Resources/templates/overview.xml
cp app/Resources/templates/complex.xml.dist app/Resources/templates/complex.xml
```
You can add more templates by simply adding more files in this folder. Use the `default.xml.dist`-file as an example.

#### Init Content Repository

```
app/console sulu:phpcr:init
```

#### Init Webspaces

```
app/console sulu:webspaces:init
```


#### Insert a new user
```
app/console sulu:security:user:create
```
Follow the instruction to create a new user


## What's inside?

- [admin-bundle](https://github.com/sulu-cmf/SuluAdminBundle)
- [contact-bundle](https://github.com/sulu-cmf/SuluContactBundle)
- [content-bundle](https://github.com/sulu-cmf/SuluContentBundle)
- [generator-bundle](https://github.com/sulu-cmf/SuluGeneratorBundle)
- [portal-bundle](https://github.com/sulu-cmf/SuluPortalBundle)
- [security-bundle](https://github.com/sulu-cmf/SuluSecurityBundle) (included but not integrated in other bundles)
- [sulu-core](https://github.com/sulu-cmf/sulu)
- [tag-bundle](https://github.com/sulu-cmf/SuluTagBundle)
- [test-bundle](https://github.com/sulu-cmf/SuluTestBundle)
- [website-bundle](https://github.com/sulu-cmf/SuluWebsiteBundle)

## Usage

The route to the backend login is:

```
sulu.lo/admin/
```

## Documentation

Documentation can be found here: [https://github.com/sulu-cmf/docs](https://github.com/sulu-cmf/docs)
