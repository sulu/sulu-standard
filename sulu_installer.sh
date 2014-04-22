#!/bin/bash
#
# This file is part of the Sulu CMS.
#
# (c) MASSIVE ART WebServices GmbH
#
# This source file is subject to the MIT license that is bundled
# with this source code in the file LICENSE.
#

# Installation note:
# To install SULU 2 by using this installer script without downloading you can
# execute it by using its URL:
#
# bash <(curl -s https://github.com/sulu-cmf/sulu-installer.sh) ARG1 ARG2 ...
#
# or
# 
# bash <(wget -q0- https://github.com/sulu-cmf/sulu-installer.sh) ARG1 ARG2 ...


SULU_PROJECT="SULU 2"
SULU_INSTALLER_NAME="${SULU_PROJECT} Installer"
SULU_INSTALLER_VERSION="0.0.1"
SULU_INSTALLER_AUTHOR="MASSIVE ART WebServices GmbH"

SULU_PROJECT_INSTALL_PATH='.'
SULU_PROJECT_CLONE_NAME='sulu-standard'
SULU_PROJECT_ABSOLUTE_PATH=${SULU_PROJECT_INSTALL_PATH}/${SULU_PROJECT_CLONE_NAME}

# some colors
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_BROWN='\033[0;33m'
COLOR_NONE='\033[0m'
COLOR_BLACK_BOLD='\033[1;30m'

# some commands
CMD_COMPOSER=`type -P composer`
CMD_GIT=`type -P git`
CMD_PHP=`type -P php`
CMD_MYSQL=`type -P mysql`
CMD_APP_CONSOLE='app/console'

# some defaults
DB_CREATE='no'
PLATTFORM=''
TMP_FILE='/tmp/.sulu_installer'

# instalation user:group
INSTALL_USER=`whoami`
INSTALL_GROUP=`id -g -n ${INSTALL_USER}`



#------------------------------------------------------------------------------
# Section: functions

say() {
	printf "* %-68s" "$1"
}

say_error() {
	printf '\033[0;31m%s\033[0m: %-s\n' "ERROR" "$1" 
	if [[ ! -z $2 ]]; then
		printf "%-7s%-s\n" " " "$2"
	fi
}

task_done() {
	printf "[${COLOR_GREEN}OK${COLOR_NONE}]\n"
}

task_failed() {
	printf "[${COLOR_RED}FAILED${COLOR_NONE}]\n"
}

section() {
	SECTION=`echo $1 | awk '{ print toupper($0) }'`
	printf "\n${COLOR_BLACK_BOLD}%-s${COLOR_NONE}\n" "${SECTION}"
}

abort() {
	echo
	exit 1
}

show_version() {
	echo ${SULU_INSTALLER_NAME} v${SULU_INSTALLER_VERSION}, ${SULU_INSTALLER_AUTHOR}
}

usage() {
	SCRIPT_NAME=`basename ${0}`
	show_version
	echo
	cat <<EOT
USAGE: ${SCRIPT_NAME} [OPTIONS]
OPTIONS:

    -h                      Show this help message.
    -v                      Prints the installer version.
    -p INSTALLATION_PATH    The path where you want to install '${SULU_PROJECT}'.
    -n INSTALLATION_NAME    The clone name. Specify the name of the directory where the installer 
                            should clone the Github repository into.
    -d                      Create database and schema (default: no).
    -m MYSQL_BINARY_PATH    Specifies the path where your MySQL binaries are installed.

EOT

}

# console_input() accepts 3 parameters:
# [1] the label (message) for the input
# [2] a default value
# [3] a flag that determines whether the input field is for a password (1) or not (0)
console_input() {
	MESSAGE=${1}
	DEFAULT_VALUE=${2}
	
	IS_PASSWORD=0
	if [ ! -z ${3} ]; then
		IS_PASSWORD=${3}
		if [ ${IS_PASSWORD} -eq 1 ]; then
			IS_PASSWORD=1
		fi
	fi
	
	if [[ ${DEFAULT_VALUE} = "" ]]; then
		printf "  * %-66s" "${MESSAGE}: "
	else
		printf "  * %-66s" "${MESSAGE} (${DEFAULT_VALUE}): "
	fi
	
	if [ ${IS_PASSWORD} -eq 1 ]; then
		stty -echo
		read -p "" INPUT_VALUE; echo
		stty echo
	else
		read -p "" INPUT_VALUE
	fi
	
	COLOR=${COLOR_BLACK_BOLD}
	if [ -z ${INPUT_VALUE} ]; then
		INPUT_VALUE=${DEFAULT_VALUE}
	else
		COLOR=${COLOR_BROWN}
	fi

	# terminal output
	if [[ ${DEFAULT_VALUE} = "" ]]; then
		printf "\033[1A  * %-66s${COLOR}%s${COLOR_NONE}\n" "${MESSAGE}: " "${INPUT_VALUE}"
	else
		if [ ${IS_PASSWORD} -eq 1 ]; then
			printf "\033[1A  * %-66s\n" "${MESSAGE} (${DEFAULT_VALUE}): "
		else
			printf "\033[1A  * %-66s${COLOR}%s${COLOR_NONE}\n" "${MESSAGE} (${DEFAULT_VALUE}): " "${INPUT_VALUE}"
		fi
	fi

	# write value to file
	printf "%s\n" ${INPUT_VALUE} >> ${TMP_FILE}
}

php_check() {
	PHP_MAYOR_MIN_VERSION='5'
	PHP_MINOR_MIN_VERSION='4'

	say "Checking PHP..."
	
	if [ -z ${CMD_PHP} ]; then
		task_failed
		say_error "It seems there is no PHP installed. Please install PHP first and try again."
		abort
	fi
	
	PHP_VERSION=`${CMD_PHP} --version 2>&1 |grep '^PHP [0-9]\.*'| awk -F' ' '{ print $2 }'`
	PHP_VERSION_MAJOR=`echo ${PHP_VERSION} | awk -F'.' '{ print $1 }'`
	PHP_VERSION_MINOR=`echo ${PHP_VERSION} | awk -F'.' '{ print $2 }'`

	if [[ ((${PHP_VERSION_MAJOR} < ${PHP_MAYOR_MIN_VERSION})) || ((${PHP_VERSION_MINOR} < ${PHP_MINOR_MIN_VERSION})) ]]; then
		task_failed
		say_error	"The installed PHP version doesn't match minimum requirements." \
					"You must have installed PHP ${PHP_MAYOR_MIN_VERSION}.${PHP_MINOR_MIN_VERSION} at least. Your version is ${PHP_VERSION}"
		abort
	fi

	task_done
}

mysql_check() {
	say "Checking MySQL..."

	if [ -z ${CMD_MYSQL} ]; then
		task_failed
		say_error "It seems there is no MySQL installed. Please install MySQL first and try again." \
		          "If MySQL is already installed you can specify the path where the binary can be found using the command line option '-m'."
		abort
	fi

	task_done
}

git_check() {
	say "Checking GIT..."

	if [ -z ${CMD_GIT} ]; then
		task_failed
		say_error "It seems there is no Git installed. Please install Git first and try again."
		abort
	fi

	task_done
}

composer_check() {
	say "Checking Composer..."

	if [ -z ${CMD_COMPOSER} ]; then
		task_failed
		say_error "It seems there is no Composer installed."
		read -p "Would you like to install composer now (y/n): " YesNo
		case ${YesNo} in
			[Yy]*)	composer_get
					;;
			[Nn]*)	abort
					;;
				*)	composer_check
				;;
		esac
	fi

	task_done
}

composer_get() {
	say "Downloading and installing Composer..."
	cd /tmp
	`which curl` -sS http://getcomposer.org/installer | php >/dev/null 2>&1
	mv composer.phar /usr/local/bin/composer >/dev/null 2>&1
	CMD_COMPOSER=`which composer`
	task_done
}

composer_install_dependencies() {
	echo "Installing all project dependencies may take a while."
	echo "So, keep calm dude..."
	say "Downloading and installing project dependencies..."
	${CMD_COMPOSER} install < ${TMP_FILE} >/dev/null 2>&1
	task_done
	rm ${TMP_FILE}
}

phpcr_setup() {
	say "Setting up PHPCR..."
	
	cp app/Resources/config/phpcr_doctrine_dbal.yml.dist app/Resources/config/phpcr.yml >/dev/null 2>&1
	
	task_done
}

sulu_repo_clone() {
	GIT_REPO="https://github.com/sulu-cmf/sulu-standard.git"

	say "Getting '${SULU_PROJECT}' standard bundle..."
	${CMD_GIT} clone ${GIT_REPO} ${SULU_PROJECT_ABSOLUTE_PATH} >/dev/null 2>&1
	cd ${SULU_PROJECT_ABSOLUTE_PATH} >/dev/null 2>&1
	${CMD_GIT} checkout develop >/dev/null 2>&1
	task_done
}

sulu_get() {
	if [ -d ${SULU_PROJECT_ABSOLUTE_PATH} ]; then
		read -p "The directory '${SULU_PROJECT_CLONE_NAME}' already exists. Do you want to overide it (y/n): " YesNo
		case ${YesNo} in
			[Yy]*)	rm -rf ${SULU_PROJECT_ABSOLUTE_PATH}; sulu_repo_clone
					;;
			[Nn]*)	abort
					;;
				*)	sulu_get
					;;
		esac
	else
		sulu_repo_clone
	fi
}

sulu_init() {
	echo
	echo "Now '${SULU_PROJECT}' needs some parameters to process the installation:"

	rm ${TMP_FILE} >/dev/null 2>&1
	
	# -----------------------------------------------------------------------------
	# PLEASE DO NOT CHANGE THE ORDER OF THE FOLLOWING ENTRIES!!!
	# -----------------------------------------------------------------------------

	console_input "Which database driver do you want to use"			"pdo_mysql"
	console_input "Database host"										"127.0.0.1"
	console_input "On which port your database will be listen to"		"3306"
	console_input "Which database name do you want to use"				"sulu"
	console_input "Database user"										"root"
	console_input "Database password"									"null" 1
	console_input "Mailer transprot protocoll"							"smtp"
	console_input "Mail host ip address"								"127.0.0.1"
	console_input "User to authenticate on mail host"					"null"
	console_input "Password for mail host authentication"				"null"
	console_input "Language for your '${SULU_PROJECT}' installation"	"en"
	console_input "Symfony 2 CSRF Secret"								"ThisTokenIsNotSoSecretChangeIt"
	console_input "Full name of Sulu admin"								"SULU 2"

	# Content fallback intervall
	echo 5000 >> ${TMP_FILE}
	# Content preview port
	echo 9876 >> ${TMP_FILE}
}

sulu_configure() {
	say "Configuring Webspaces..."
	cp app/Resources/webspaces/sulu.io.xml.dist app/Resources/webspaces/sulu.io.xml >/dev/null 2>&1
	task_done

	say "Configuring Templates..."
	cp app/Resources/templates/default.xml.dist app/Resources/templates/default.xml >/dev/null 2>&1
	cp app/Resources/templates/overview.xml.dist app/Resources/templates/overview.xml >/dev/null 2>&1
	cp app/Resources/templates/complex.xml.dist app/Resources/templates/complex.xml >/dev/null 2>&1
	task_done
}

sulu_content_repo_init() {
	say "Initializing Content Repository..."
	${CMD_APP_CONSOLE} "sulu:phpcr:init" >/dev/null 2>&1
	task_done
}

sulu_webspace_init() {
	say "Initializing Webspace..."
	${CMD_APP_CONSOLE} "sulu:webspaces:init" >/dev/null 2>&1
	task_done
}

sulu_user_new() {
	printf "%-70s" "Do you want to create a new user (y/n): "
	read -p "" YesNo

	case ${YesNo} in
		[Yy]*)	sulu_user_new_questions
				sulu_user_create
				;;

		[Nn]*)	echo
				;;
				
			*)	sulu_user_new
				;;
	esac
	
}

sulu_user_new_questions() {
	rm ${TMP_FILE} >/dev/null 2>&1
	
	# -----------------------------------------------------------------------------
	# PLEASE DO NOT CHANGE THE ORDER OF THE FOLLOWING ENTRIES!!!
	# -----------------------------------------------------------------------------

	console_input "Please choose a username"			""
	console_input "Please choose a First Name"			""
	console_input "Please choose a Last Name"			""
	console_input "Please choose an email"				""
	console_input "Please choose a locale"				""
	console_input "Please choose a password"			"" 1
}

sulu_user_create() {
	say "Creating new user..."
	${CMD_APP_CONSOLE} "sulu:security:user:create" < ${TMP_FILE} >/dev/null 2>&1
	task_done
	rm ${TMP_FILE} >/dev/null 2>&1
}

cache_reset() {
	say "Initializing caches..."
	
	rm -rf app/admin/cache/* >/dev/null 2>&1
	rm -rf app/admin/logs/* >/dev/null 2>&1
	rm -rf app/website/cache/* >/dev/null 2>&1
	rm -rf app/website/logs/* >/dev/null 2>&1
	
	task_done
}

database_create() {
	DOCTRINE_CREATE_DB='doctrine:database:create'
	DOCTRINE_CREATE_SCHEMA='doctrine:schema:create'
	DOCTRINE_LOAD_FIXTURES='doctrine:fixtures:load'
	DOCTRINE_DROP_DB='doctrine:database:drop --force'
	
	if [ ${DB_CREATE} = 'yes' ]; then
		say "Creating database..."
		${CMD_APP_CONSOLE} ${DOCTRINE_DROP_DB} >/dev/null 2>&1
		${CMD_APP_CONSOLE} ${DOCTRINE_CREATE_DB} >/dev/null 2>&1
		task_done

		say "Creating schema..."
		${CMD_APP_CONSOLE} ${DOCTRINE_CREATE_SCHEMA} >/dev/null 2>&1
		task_done

		# Loading default values normally requires user interaction.
		# We will simulate it by writing the answer 'y' to a temp file...
		echo 'y' > ${TMP_FILE}

		say "Loading database default values..."
		${CMD_APP_CONSOLE} ${DOCTRINE_LOAD_FIXTURES} < ${TMP_FILE} >/dev/null 2>&1
		rm ${TMP_FILE} >/dev/null 2>&1
		task_done
	fi
}

permissions_set() {
	say "Setting up permissions..."

	PLATTFORM=`uname | awk '{ print tolower($0) }'`
	case ${PLATTFORM} in
		"darwin")	permissions_set_darwin
					;;
		"linux")	permissions_set_linux
					;;
#		"freebsd")	permissions_set_freebsd
#					;;
	esac

	task_done
}

permissions_set_darwin() {
	APACHEUSER=`ps aux | grep -E '[a]pache|[h]ttpd' | grep -v root | head -1 | cut -d\  -f1`
	sudo chmod +a "$APACHEUSER allow delete,write,append,file_inherit,directory_inherit" app/admin/cache app/admin/logs app/website/cache app/website/logs
	sudo chmod +a "${INSTALL_USER} allow delete,write,append,file_inherit,directory_inherit" app/admin/cache app/admin/logs app/website/cache app/website/logs
}

permissions_set_linux() {
	sudo setfacl -R -m u:www-data:rwx -m u:${INSTALL_USER}:rwx app/admin/cache app/admin/logs app/website/cache app/website/logs
	sudo setfacl -dR -m u:www-data:rwx -m u:${INSTALL_USER}:rwx app/admin/cache app/admin/logs app/website/cache app/website/logs
}

#permissions_set_freebsd() {
#
#}

closing_remarks() {
	printf "=%.0s" {1..74}
	printf "\n"
	printf "${COLOR_BLACK_BOLD}\o/ Hurray \o/ - You have successfully installed '${SULU_PROJECT}'${COLOR_NONE}\n"
	printf "=%.0s" {1..74}
	printf "\n"
	cat <<EOT
	
Please don't forget to setup your virtual host! You may use this template:

<VirtualHost *:80>
    DocumentRoot "${SULU_PROJECT_ABSOLUTE_PATH}/web"
    ServerName sulu.lo
    <Directory "${SULU_PROJECT_ABSOLUTE_PATH}/web">
        Options Indexes FollowSymlinks
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>

EOT
	printf "=%.0s" {1..74}
	echo
}



#------------------------------------------------------------------------------
# Section: Parameter parsing

while getopts hvp:n:dm: option
do
	case $option in
		h)	usage; abort
			;;
			
		\?)	usage; abort
			;;
			
		v)	show_version; exit
			;;
			
		p)	SULU_PROJECT_INSTALL_PATH=${OPTARG%/}
			;;
			
		n)	SULU_PROJECT_CLONE_NAME=${OPTARG%/}
			;;
			
		d)	DB_CREATE='yes'
			;;
			
		m)	MYSQL_INSTALL_PATH=${OPTARG%/}
			CMD_MYSQL="${MYSQL_INSTALL_PATH}/mysql"
			if [ ! -f ${CMD_MYSQL} ]; then
				say_error "The mysql binary doesn't exists at: ${MYSQL_INSTALL_PATH}/"
				abort
			fi
			;;
	esac
done

SULU_PROJECT_ABSOLUTE_PATH=${SULU_PROJECT_INSTALL_PATH}/${SULU_PROJECT_CLONE_NAME}


#------------------------------------------------------------------------------
# Section: root check

if [ "$(id -u)" != "0" ]; then
	say_error "The installation must be run as root!"
    exit 1
fi



#------------------------------------------------------------------------------
# Section: Installation process

show_version


# first, let's make some checks...
section "Requirements"
php_check
mysql_check
git_check
composer_check


# first, we have to grab the sulu-standard bundle
section "Sulu Setup"
sulu_get ${SULU_PROJECT_INSTALL_PATH} ${SULU_PROJECT_CLONE_NAME}

# setting up basic application parameters
sulu_init


# setting up PHPCR session
section "PHPCR Session"
phpcr_setup


# download and install dependencies
section "Dependencies"
cd ${SULU_PROJECT_ABSOLUTE_PATH}
composer_install_dependencies


# set permissions
section "Permissions"
permissions_set


# create databse and install default schema
section "Database"
database_create


# init all caches
section "Cache"
cache_reset


# create required configuration files
section "Configuration"
sulu_configure
sulu_content_repo_init
sulu_webspace_init


# create a new user
section "User Creation"
sulu_user_new


# Write a bunch of 'last words'...
section "We are done..."
closing_remarks

exit 0