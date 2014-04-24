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
SULU_INSTALLER_VERSION="0.1.2"
SULU_INSTALLER_AUTHOR="MASSIVE ART WebServices GmbH"

SULU_PROJECT_INSTALL_PATH='.'
SULU_PROJECT_CLONE_NAME='sulu-standard'
SULU_PROJECT_ABSOLUTE_PATH="${SULU_PROJECT_INSTALL_PATH}/${SULU_PROJECT_CLONE_NAME}"

# some colors
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_BROWN='\033[0;33m'
COLOR_NONE='\033[0m'
COLOR_BLACK_BOLD='\033[1;30m'

# some commands
CMD_COMPOSER=$( type -P composer )
CMD_GIT=$( type -P git )
CMD_PHP=$( type -P php )
CMD_APP_CONSOLE='app/console'

# some defaults
DB_CREATE='no'
PLATTFORM=''
MYSQL_INSTALL_PATH=''
TMP_FILE=$( mktemp -q /tmp/sulu_instaler.XXXXXXXXXXXXXXXXXXXXXXX )
PARAMETERS_YML='/tmp/parameters.yml'


# installation user
INSTALL_USER=$USER
SULU_DBAL='mysql'


# Reset terminal to current state when we exit.
trap "stty $(stty -g)" EXIT


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
	SECTION=$( echo $1 | awk '{ print toupper($0) }' )
	printf "\n${COLOR_BLACK_BOLD}%-s${COLOR_NONE}\n" "${SECTION}"
}

abort() {
	echo
	exit 1
}

show_version() {
	echo ${SULU_INSTALLER_NAME} v${SULU_INSTALLER_VERSION}, ${SULU_INSTALLER_AUTHOR}
}

reset_tmp_file() {
	rm -f "${TMP_FILE}"
	touch "${TMP_FILE}" >/dev/null 2>&1 
}

usage() {
	SCRIPT_NAME=$( basename ${0} )
	show_version
	echo
	cat <<EOT
USAGE: ${SCRIPT_NAME} [OPTIONS]
OPTIONS:

    -h                      Show this help message
    -v                      Prints the installer version
    -p INSTALLATION_PATH    The path where you want to install '${SULU_PROJECT}' (default: ./)
    -n INSTALLATION_NAME    The clone name. Specify the name of the directory where the installer 
                            should clone the Github repository into (default: '${SULU_PROJECT_CLONE_NAME}')
    -d                      Create database and schema (default: no)
    -P                      Use PostgeSQL as database instead of MySQL (default: MySQL)
    -m MYSQL_BINARY_PATH    Specifies the path where your MySQL binaries are installed

EOT

}

# console_input() accepts 4 parameters:
# [1] the label (message) for the input
# [2] a default value
# [3] a flag that determines whether the input field is for a password (1) or not (0)
# [4] a flag that determines whether the input should be concatenated (1) to the temp file or written as single value (0)
console_input() {
	MESSAGE=${1}
	DEFAULT_VALUE=${2}
	
	IS_PASSWORD=0
	if [ ! -z ${3} ]; then IS_PASSWORD=${3}; fi
	
	APPEND=1
	if [ ! -z ${4} ]; then APPEND=${4}; fi
	
	if [[ ${DEFAULT_VALUE} = "" ]]; then
		printf "  %-68s" "${MESSAGE}: "
	else
		printf "  %-68s" "${MESSAGE} (${DEFAULT_VALUE}): "
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
	if [ ${IS_PASSWORD} -eq 1 ]; then
		printf "\033[1A  %-68s\n" "${MESSAGE} (${DEFAULT_VALUE}): "
	else
		if [[ ${DEFAULT_VALUE} = "" ]]; then
			printf "\033[1A  %-68s${COLOR}%s${COLOR_NONE}\n" "${MESSAGE}: " "${INPUT_VALUE}"
		else
			printf "\033[1A  %-68s${COLOR}%s${COLOR_NONE}\n" "${MESSAGE} (${DEFAULT_VALUE}): " "${INPUT_VALUE}"
		fi
	fi

	# write value to file
	if [ ${APPEND} -eq 1 ]; then
		echo "${INPUT_VALUE}" >> "${TMP_FILE}"
	else
		echo "${INPUT_VALUE}" > "${TMP_FILE}"
	fi
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
	
	PHP_VERSION=$( ${CMD_PHP} --version 2>&1 |grep '^PHP [0-9]\.*'| awk -F' ' '{ print $2 }' )
	PHP_VERSION_MAJOR=$( echo ${PHP_VERSION} | awk -F'.' '{ print $1 }' )
	PHP_VERSION_MINOR=$( echo ${PHP_VERSION} | awk -F'.' '{ print $2 }' )

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

	CMD_MYSQL=$( type -P mysql )
	if [ -z ${CMD_MYSQL} ]; then
		task_failed
		say_error "It seems there is no MySQL installed. Please install MySQL first and try again." \
		          "If MySQL is already installed you can specify the path where the binary can be found using the command line option '-m'."
		abort
	fi

	task_done
}

pgsql_check() {
	say "Checking PostgreSQL..."

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
	$( type -P curl ) -sS http://getcomposer.org/installer | php >/dev/null 2>&1 
	mv composer.phar /usr/local/bin/composer >/dev/null 2>&1 
	CMD_COMPOSER=$( which composer )
	task_done
}

composer_install_dependencies() {
	cd ${SULU_PROJECT_ABSOLUTE_PATH}
	printf "${COLOR_BLACK_BOLD}Note:${COLOR_NONE} Installing all project dependencies may take a while.\n"
	printf "So, keep calm dude...\n\n"
	say "Downloading and installing project dependencies..."
	
	${CMD_COMPOSER} update --no-interaction >/dev/null 2>&1 
	
	# Since we set the option '--no-interaction' on composer the 'parameters.yml' file will be
	# auto generated using the 'parameters.yml.dist' file. We have to overide this file!
	mv ${PARAMETERS_YML} 'app/Resources/config/parameters.yml'
	
	task_done
}

phpcr_setup() {
	phpcr_setup_interaction

	say "Setting up PHPCR..."
	case ${PHPCR_SELECTION} in
		doctrine)	cp app/Resources/config/phpcr_doctrine_dbal.yml.dist app/Resources/config/phpcr.yml >/dev/null 2>&1 
					;;
					
		jackrabbit)	cp app/Resources/config/phpcr_jackrabbit.yml.dist app/Resources/config/phpcr.yml >/dev/null 2>&1 
					;;
	esac
	
	task_done
}

phpcr_setup_interaction() {
	reset_tmp_file
	console_input "Do you want to use Doctrine-DBAL (d) or Jackrabbit (j)?" "d"
	case $( cat "${TMP_FILE}" ) in
		[Dd]*)	PHPCR_SELECTION="doctrine"
				;;
				
		[Jj]*)	PHPCR_SELECTION="jackrabbit"
				;;
				
			*)	printf "\033[1A"; phpcr_setup_interaction
				;;
	esac
}

sulu_repo_clone() {
	GIT_REPO="https://github.com/sulu-cmf/sulu-standard.git"
	
	say "Downloading '${SULU_PROJECT}' standard bundle..."
	${CMD_GIT} clone ${GIT_REPO} ${SULU_PROJECT_ABSOLUTE_PATH} >/dev/null 2>&1 
	cd ${SULU_PROJECT_ABSOLUTE_PATH} >/dev/null 2>&1 
	${CMD_GIT} checkout develop >/dev/null 2>&1 
	task_done
}

sulu_get() {
	if [ -d ${SULU_PROJECT_ABSOLUTE_PATH} ]; then
		reset_tmp_file
		echo "The directory '${SULU_PROJECT_CLONE_NAME}' already exists."
		console_input "Do you want to replace (r) it, use it (u) or abort (a)" ""
		YesNo=$( cat "${TMP_FILE}" | sed s/\n//g )
		case ${YesNo} in
			[Rr]*)	say "Removing existing installation..."
					rm -rf ${SULU_PROJECT_ABSOLUTE_PATH}
					task_done
					
					sulu_repo_clone
					;;
					
			[Aa]*)	abort
					;;
					
			[Uu]*)	;;
		esac
	else
		sulu_repo_clone
	fi
}

sulu_init() {
	echo "Now '${SULU_PROJECT}' needs some parameters to process the installation:"
	echo
	
	# generate a custom 'parameters.yml' file
	echo "# parameters.yml - auto generated file by SULU installer
parameters:" > ${PARAMETERS_YML}

	reset_tmp_file
	
	# -----------------------------------------------------------------------------
	# PLEASE DO NOT CHANGE THE ORDER OF THE FOLLOWING ENTRIES!!!
	# -----------------------------------------------------------------------------

	case ${SULU_DBAL} in
		mysql)	DB_DRIVER='pdo_mysql'
				DB_PORT="3306"
				;;

		pgsql)	DB_DRIVER='pdo_pgsql'
				DB_PORT="5432"
				;;
	esac
	echo  "   database_driver: ${DB_DRIVER}" >> ${PARAMETERS_YML}
	
	console_input "Database host" "127.0.0.1" 0 0
	echo -n "   database_host: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}
	
	console_input "On which port your database will be listen to" ${DB_PORT} 0 0
	echo -n "   database_port: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Which database name do you want to use" "sulu" 0 0
	echo -n "   database_name: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Database user" "root" 0 0
	echo -n "   database_user: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Database password" "null" 1 0
	echo -n "   database_password: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Mailer transprot protocoll" "smtp" 0 0
	echo -n "   mailer_transport: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Mail host ip address" "127.0.0.1" 0 0
	echo -n "   mailer_host: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "User to authenticate on mail host" "null" 0 0
	echo -n "   mailer_user: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Password for mail host authentication" "null" 0 0
	echo -n "   mailer_password: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Language for your '${SULU_PROJECT}' installation" "en" 0 0
	echo -n "   locale: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Symfony 2 CSRF Secret" "ThisTokenIsNotSoSecretChangeIt" 1 0
	echo -n "   secret: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	console_input "Full name of Sulu admin" "SULU 2" 0 0
	echo -n "   sulu_admin.name: " >> ${PARAMETERS_YML}; cat ${TMP_FILE} >> ${PARAMETERS_YML}

	# Content fallback intervall
	echo "   content_fallback_intervall: 5000" >> ${PARAMETERS_YML}
	# Content preview port
	echo "   content_preview_port: 9876" >> ${PARAMETERS_YML}
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
			*)	printf "\033[1A"; sulu_user_new
				;;
	esac
	
}

sulu_user_new_questions() {
	reset_tmp_file
	
	# -----------------------------------------------------------------------------
	# PLEASE DO NOT CHANGE THE ORDER OF THE FOLLOWING ENTRIES!!!
	# -----------------------------------------------------------------------------

	console_input "Please choose an username"			""
	console_input "Please choose a First Name"			""
	console_input "Please choose a Last Name"			""
	console_input "Please choose an email address"		""
	console_input "Please choose a locale"				""
	console_input "Please choose a password"			"" 1
}

sulu_user_create() {
	say "Creating new user..."
	${CMD_APP_CONSOLE} "sulu:security:user:create" < "${TMP_FILE}" >/dev/null 2>&1 
	task_done
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
	if [ ${DB_CREATE} = 'yes' ]; then
		# we need to drain the cache since 'app/console' is using
		# the cached 'parameters.yml' instead of our own!
		rm -rf app/admin/cache/* >/dev/null 2>&1 
		
		say "Creating database..."
		ERROR="$( ${CMD_APP_CONSOLE} doctrine:database:drop --force | sed s/\"/\'/g >/dev/null 2>&1 )"
		if [ ! -z "${ERROR}" ]; then echo; say_error "${ERROR}"; abort; fi

		ERROR="$( ${CMD_APP_CONSOLE} doctrine:database:create | sed s/\"/\'/g >/dev/null 2>&1 )"
		if [ ! -z "${ERROR}" ]; then echo; say_error "${ERROR}"; abort; fi
		task_done
		
		say "Creating schema..."
		ERROR="$( ${CMD_APP_CONSOLE} doctrine:schema:create | sed s/\"/\'/g >/dev/null 2>&1 )"
		if [ ! -z "${ERROR}" ]; then echo; say_error "${ERROR}"; abort; fi
		task_done

		# Loading default values normally requires user interaction.
		# We will simulate it by writing the answer 'y' to a temp file...
		echo 'y' > "${TMP_FILE}"

		say "Loading database default values..."
		ERROR="$( ${CMD_APP_CONSOLE} doctrine:fixtures:load < "${TMP_FILE}" | sed s/\"/\'/g >/dev/null 2>&1 )"
		if [ ! -z "${ERROR}" ]; then echo; say_error "${ERROR}"; abort; fi
		task_done
	fi
}

permissions_set() {
	say "Setting up permissions..."

	PLATTFORM=$( uname | awk '{ print tolower($0) }' )
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
	APACHEUSER=$( ps aux | grep -E '[a]pache|[h]ttpd' | grep -v root | head -1 | cut -d\  -f1 )
	sudo chmod +a -R "$APACHEUSER allow delete,write,append,file_inherit,directory_inherit" app/admin/cache app/admin/logs app/website/cache app/website/logs>/dev/null 2>&1 
	sudo chmod +a -R "${INSTALL_USER} allow delete,write,append,file_inherit,directory_inherit" app/admin/cache app/admin/logs app/website/cache app/website/logs >/dev/null 2>&1 
}

permissions_set_linux() {
	sudo setfacl -R -m u:www-data:rwx -m u:${INSTALL_USER}:rwx app/admin/cache app/admin/logs app/website/cache app/website/logs >/dev/null 2>&1 
	sudo setfacl -dR -m u:www-data:rwx -m u:${INSTALL_USER}:rwx app/admin/cache app/admin/logs app/website/cache app/website/logs >/dev/null 2>&1 
}

#permissions_set_freebsd() {
#
#}

local_test_host() {
	echo "In case of this is a local development installation '${SULU_PROJECT}' uses a"
	echo "special localhost alias named 'sulu.lo'."
	echo
	echo "This alias must be added in '/etc/hosts'."
	echo
	console_input "Should I do that for you (y/n)"
	YesNo=$( cat "${TMP_FILE}" | sed s/\n//g )
	case ${YesNo} in
		[Yy]*)	local_test_host_add
				;;
		[Nn]*)	;;
			*)	printf "\033[1A\033[1A\033[1A\033[1A\033[1A"; local_test_host
				;;
	esac
}

local_test_host_add() {
	say "Adding 'sulu.lo' alias to '/etc/hosts'"
	TESTHOST=$( cat /etc/hosts | grep 'sulu.lo' | awk 'BEGIN { FS = "[ \t]+" } ; { print $2 }' )
	if [ -z ${TESTHOST} ]; then
		printf "\n# ${SULU_PROJECT} test host alias\n" >> /etc/hosts
		printf "127.0.0.1	sulu.lo" >> /etc/hosts
	fi
	task_done
}

closing_remarks() {
	printf "=%.0s" {1..74}
	printf "\n"
	FIGLET=$( type -P figlet )
	if [ ! -z FIGLET ];
		then ${FIGLET} -w 75 -c '\o/ Hurray \o/'
	else
		printf "                              ${COLOR_BLACK_BOLD}\o/ Hurray \o/${COLOR_NONE}\n"
	fi
	printf "\n"
	printf "                 You have successfully installed ${COLOR_BLACK_BOLD}'${SULU_PROJECT}'${COLOR_NONE}\n"
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

error_msg_db_ambiguity() {
	say_error "Using both options '-P' and '-m' makes no sense because of they're addressing two different databases."
	abort
}



#------------------------------------------------------------------------------
# Section: Parameter parsing

while getopts hvp:n:dPm: option
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
			
		P)	SULU_DBAL='pgsql'
			if [ ! -z ${MYSQL_INSTALL_PATH} ]; then
				error_msg_db_ambiguity
			fi
			;;
			
		m)	MYSQL_INSTALL_PATH=${OPTARG%/}
			if [ "${SULU_DBAL}" = "pgsql" ]; then
				error_msg_db_ambiguity
			else
				CMD_MYSQL="${MYSQL_INSTALL_PATH}/mysql"
				if [ ! -f ${CMD_MYSQL} ]; then
					say_error "The mysql binary doesn't exists at: ${MYSQL_INSTALL_PATH}/"
					abort
				fi
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
git_check
composer_check

case ${SULU_DBAL} in
	mysql)	mysql_check
			;;
	pgsql)	pgsql_check
			;;
esac


# first, we have to grab the sulu-standard bundle
section "Installation"
sulu_get ${SULU_PROJECT_INSTALL_PATH} ${SULU_PROJECT_CLONE_NAME}


# setting up PHPCR session
section "PHPCR"
phpcr_setup


# setting up basic application parameters
section "Initialization"
sulu_init


# download and install dependencies
section "Dependencies"
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


# manipulate /etc/hosts by inserting an alias for sulu.lo
section "Local Test-Host"
local_test_host



# Write a bunch of 'last words'...
section "We are done..."
closing_remarks

exit 0