#!/usr/bin/env bash

#
# Script to install Magento2
#
# @author   Raj KB <magepsycho@gmail.com>
# @website  http://www.magepsycho.com
# @version  0.1.0

# UnComment it if bash is lower than 4.x version
shopt -s extglob

################################################################################
# CORE FUNCTIONS - Do not edit
################################################################################

## Uncomment it for debugging purpose
###set -o errexit
#set -o pipefail
#set -o nounset
#set -o xtrace

#
# VARIABLES
#
_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)

_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)

#
# HEADERS & LOGGING
#
function _debug()
{
    if [[ "$DEBUG" = 1 ]]; then
        "$@"
    fi
}

function _header()
{
    printf '\n%s%s==========  %s  ==========%s\n' "$_bold" "$_purple" "$@" "$_reset"
}

function _arrow()
{
    printf '➜ %s\n' "$@"
}

function _success()
{
    printf '%s✔ %s%s\n' "$_green" "$@" "$_reset"
}

function _error() {
    printf '%s✖ %s%s\n' "$_red" "$@" "$_reset"
}

function _warning()
{
    printf '%s➜ %s%s\n' "$_tan" "$@" "$_reset"
}

function _underline()
{
    printf '%s%s%s%s\n' "$_underline" "$_bold" "$@" "$_reset"
}

function _bold()
{
    printf '%s%s%s\n' "$_bold" "$@" "$_reset"
}

function _note()
{
    printf '%s%s%sNote:%s %s%s%s\n' "$_underline" "$_bold" "$_blue" "$_reset" "$_blue" "$@" "$_reset"
}

function _die()
{
    _error "$@"
    exit 1
}

function _safeExit()
{
    exit 0
}

#
# UTILITY HELPER
#
function _seekConfirmation()
{
  printf '\n%s%s%s' "$_bold" "$@" "$_reset"
  read -p " (y/n) " -n 1
  printf '\n'
}

# Test whether the result of an 'ask' is a confirmation
function _isConfirmed()
{
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1
}


function _typeExists()
{
    if type "$1" >/dev/null; then
        return 0
    fi
    return 1
}

function _isOs()
{
    if [[ "${OSTYPE}" == $1* ]]; then
      return 0
    fi
    return 1
}

function _checkRootUser()
{
    #if [ "$(id -u)" != "0" ]; then
    if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
    fi

}

function _printPoweredBy()
{
    local mp_ascii
    mp_ascii='
   __  ___              ___               __
  /  |/  /__ ____ ____ / _ \___ __ ______/ /  ___
 / /|_/ / _ `/ _ `/ -_) ___(_-</ // / __/ _ \/ _ \
/_/  /_/\_,_/\_, /\__/_/  /___/\_, /\__/_//_/\___/
            /___/             /___/
'
    cat <<EOF
${_green}
Powered By:
$mp_ascii

 >> Store: ${_reset}${_underline}${_blue}http://www.magepsycho.com${_reset}${_reset}${_green}
 >> Blog:  ${_reset}${_underline}${_blue}http://www.blog.magepsycho.com${_reset}${_reset}${_green}

################################################################
${_reset}
EOF
}

################################################################################
# SCRIPT FUNCTIONS
################################################################################
function _printUsage()
{
    echo -n "$(basename "$0") [OPTION]...

Simplified Magento2 Installer
Version $VERSION

    Options:
        --source                    Installation source (Default: tar)
        --edition                   Magento2 edition (Default: community)
        --version                   Magento2 version
                                    Refer - https://github.com/magento/magento2/releases
        --install-dir               Magento2 installation directory (Default: Current)
        --base-url                  Base URL
        --install-sample-data       Install sample data (Default: 0)
        --setup-mode                Setup Mode (Default: developer)

        --db-host                   DB host (Default: localhost)
        --db-user                   DB user (Default: root)
        --db-pass                   DB pass
        --db-name                   DB name
        --db-prefix                 DB prefix

        --admin-firstname           Admin firstname (Default: John)
        --admin-lastname            Admin lastname (Default: Doe)
        --admin-email               Admin email (Default: admin@example.com)
        --admin-user                Admin user (Default: admin)
        --admin-password            Admin password

        --language                  Language (Default: en_US)
        --currency                  Currency (Default: USD)
        --timezone                  Timezone (Default: America/Chicago)

        -h,     --help              Display this help and exit

    Examples:
        $(basename "$0") --version=... --base-url=... --install-sample-data --db-user=... --db-pass=... --db-name=...

"
    _printPoweredBy
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
            --source=*)
                INSTALL_SOURCE="${arg#*=}"
            ;;
            --source-path=*)
                SOURCE_PATH="${arg#*=}"
            ;;
            --edition=*)
                M2_EDITION="${arg#*=}"
            ;;
            --version=*)
                M2_VERSION="${arg#*=}"
            ;;
            --download-dir=*)
                DOWNLOAD_DIR="${arg#*=}"
            ;;
            #--create-virtual-host)
            #    CREATE_VIRTUAL_HOST=1
            #;;
            --install-dir=*)
                INSTALL_DIR="${arg#*=}"
            ;;
            --install-sample-data)
                INSTALL_SAMPLE_DATA=1
            ;;
            --setup-mode=*)
                M2_SETUP_MODE="${arg#*=}"
            ;;
            --base-url=*)
                BASE_URL="${arg#*=}"
            ;;
            --db-host=*)
                DB_HOST="${arg#*=}"
            ;;
            --db-user=*)
                DB_USER="${arg#*=}"
            ;;
            --db-pass=*)
                DB_PASS="${arg#*=}"
            ;;
            --db-name=*)
                DB_NAME="${arg#*=}"
            ;;
            --db-prefix=*)
                DB_PREFIX="${arg#*=}"
            ;;
            --admin-firstname=*)
                ADMIN_FIRSTNAME="${arg#*=}"
            ;;
            --admin-lastname=*)
                ADMIN_LASTNAME="${arg#*=}"
            ;;
            --admin-email=*)
                ADMIN_EMAIL="${arg#*=}"
            ;;
            --admin-user=*)
                ADMIN_USER="${arg#*=}"
            ;;
            --admin-password=*)
                ADMIN_PASSWORD="${arg#*=}"
            ;;
            --language=*)
                LANGUAGE="${arg#*=}"
            ;;
            --currency=*)
                CURRENCY="${arg#*=}"
            ;;
            --timezone=*)
                TIMEZONE="${arg#*=}"
            ;;
            --debug)
                DEBUG=1
                set -o xtrace
            ;;
            -h|--help)
                _printUsage
            ;;
            *)
                _printUsage
            ;;
        esac
    done

    validateArgs
    sanitizeArgs
}

function validateArgs()
{
    ERROR_COUNT=0
    # Check Version, if not empty check if corresponding .tar.gz git URL exists
    if [[ -z "$M2_VERSION" ]]; then
        _error "--version parameter missing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ ! -z "$M2_VERSION" ]]; then
        prepareM2GitTarUrl
        if ! `validateUrl $SOURCE_PATH`; then
            _error "Magento2 tar with version '${M2_VERSION}' doesn't exist."
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi

    # Prepare & validate installation directory
    if [[ ! -z "$INSTALL_DIR" ]]; then
        prepareInstallDir
        if ! mkdir -p "$INSTALL_DIR"; then
            _error "--install-dir is not writable."
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi

    if [[ -z "$BASE_URL" ]]; then
        _error "--base-url parameter missing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    # Check db parameters
    if [[ -z "$DB_PASS" ]]; then
        _error "--db-pass parameter missing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ -z "$DB_NAME" ]]; then
        _error "--db-name parameter missing."
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi

    if [[ ! -z "$DB_PASS" ]] && [[ ! -z "$DB_NAME" ]]; then
        mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e exit
        if [[ $? -eq 0 ]]; then
            if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE $DB_NAME"; then
                _error "Database '$DB_NAME' already exists."
                ERROR_COUNT=$((ERROR_COUNT + 1))
            fi
        else
            _error "Unable to connect the database. Please re-check the --db-* parameters."
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi

    [[ "$ERROR_COUNT" -gt 0 ]] && exit 1
}

function validateUrl ()
{
    #if [[ `curl -s --head "$1" | head -n 1 | grep "HTTP/[1-3].[0-9] [23].."` ]]
    if [[ `wget -S --no-check-certificate --secure-protocol=TLSv1_2 --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
        # 0 = true
        return 0
    else
        # 1 = false
        return 1
    fi
}

function sanitizeArgs()
{
    # remove trailing /
    if [[ ! -z "$INSTALL_DIR" ]]; then
        INSTALL_DIR="${INSTALL_DIR%/}"
    fi
    if [[ ! -z "$DOWNLOAD_DIR" ]]; then
        DOWNLOAD_DIR="${DOWNLOAD_DIR%/}"
    fi
}

function prepareDownloadDir()
{
    DOWNLOAD_DIR=/tmp
}

function prepareBaseUrl()
{
    BASE_URL="http://$(getDomainFromUrl)/"
}

function prepareSecureBaseUrl()
{
    BASE_URL_SECURE="https://$(getDomainFromUrl)"
}

function getDomainFromUrl()
{
    echo "$BASE_URL" | sed -e 's|^[^/]*//||' -e 's|/.*$||'
}

function prepareM2GitTarUrl()
{
    SOURCE_PATH="https://github.com/magento/magento2/archive/${M2_VERSION}.tar.gz"
}

function prepareInstallDir()
{
    # INSTALL_DIR is overridden by CLI args
    CURRENT_DIR=$(basename "$INSTALL_DIR")
}

function genAdminFrontname()
{
    echo $(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
}

function genRandomPassword()
{
    echo $(cat /dev/urandom | env LC_CTYPE=C tr -dc '_a-zAZ_0-9&$@%' | fold -w 8 | head -n 1)
}

function installFromTar()
{
    # Check Magento dependencies
    # @todo

    # STEP 1 - Prepare & Download file
    M2_ARCHIVE_FILE="m2-${M2_EDITION}-${M2_VERSION}.tar.gz"
    M2_ARCHIVE_PATH="${DOWNLOAD_DIR}"/"${M2_ARCHIVE_FILE}"
    _arrow "Downloading Magento ${M2_VERSION}..."
    if [[ ! -f "$M2_ARCHIVE_PATH" ]]; then
        wget --no-check-certificate --secure-protocol=TLSv1_2 "$SOURCE_PATH" -O "${M2_ARCHIVE_PATH}" || _die "Download failed."
        # save for future reference @todo
    else
        _note " Skipped downloading(${M2_ARCHIVE_FILE} already exists)"
    fi

    # STEP 2 - Prepare & Install downloaded file
    mkdir -p "$INSTALL_DIR"
    ###cp "$M2_ARCHIVE_PATH" "$INSTALL_DIR" || _die "Cannot copy files to install directory."

    _arrow "Extracting files to ${INSTALL_DIR}..."
    tar -zxf "$M2_ARCHIVE_PATH" -C "${INSTALL_DIR}" || _die "Couldn't extract file: ${M2_ARCHIVE_PATH}."

    cd "$INSTALL_DIR" || _die "Couldn't change directory to : ${INSTALL_DIR}."

    # Finally move all the files from sub-folder to the www dir
    mv "magento2-$M2_VERSION"/{.[!.],}* ./ || _die "Couldn't move files to : ${INSTALL_DIR}."
    if [[ ! -f ./nginx.conf ]]; then
        cp ./nginx.conf.sample ./nginx.conf
    fi
    verifyCurrentDirIsMage2Root

    # if db already exists, throws SQL error
    _arrow "Creating database ${DB_NAME}..."
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE $DB_NAME" || _die "Couldn't create database: ${DB_NAME}."

    _arrow "Setting ownership & permissions..."
    setFilesystemPermission

    rm -rf "magento2-${M2_VERSION}"/

    _arrow "Running Composer..."
    composer install || _die "'composer install' command failed."

    _arrow "Installing Magento2..."
    prepareBaseUrl
    prepareSecureBaseUrl

    php ./bin/magento setup:install \
        --base-url="$BASE_URL" \
        --db-host="$DB_HOST" \
        --db-name="$DB_NAME" \
        --db-user="$DB_USER" \
        --db-password="$DB_PASS" \
        --backend-frontname="$BACKEND_FRONTNAME" \
        --admin-firstname="$ADMIN_FIRSTNAME" \
        --admin-lastname="$ADMIN_LASTNAME" \
        --admin-email="$ADMIN_EMAIL" \
        --admin-user="$ADMIN_USER" \
        --admin-password="$ADMIN_PASSWORD" \
        --language="$LANGUAGE" \
        --currency="$CURRENCY" \
        --timezone="$TIMEZONE" \
        --cleanup-database \
        --session-save="$SESSION_SAVE" \
        --use-rewrites=1

    # @todo ssl installation
    #--use-secure=1
    #--base-url-secure=$BASE_URL_SECURE
    #--use-secure-admin=1

    if [[ "$INSTALL_SAMPLE_DATA" -eq 1 ]]; then
        _arrow "Installing sample data..."

        # "${HOME}/.config/composer/auth.json"
        if [[ -f "${HOME}/.composer/auth.json" ]]; then
            if [[ -d ./var/composer_home ]]; then
                cp "${HOME}/.composer/auth.json" ./var/composer_home/
            fi
        fi

        composer config repositories.magento composer https://repo.magento.com

        php -d memory_limit=-1 ./bin/magento sampledata:deploy

        # Run in case of Authentication error
        ###composer update

        php -d memory_limit=-1 ./bin/magento setup:upgrade
    fi

    if [[ "$M2_SETUP_MODE" = 'developer' ]]; then
        _arrow "Setting developer mode..."
        php ./bin/magento deploy:mode:set developer
    fi

    if [[ "$M2_SETUP_MODE" = 'production' ]]; then
        _arrow "Setting production mode..."
        php ./bin/magento deploy:mode:set production
    fi
}

function setFilesystemPermission()
{
    verifyCurrentDirIsMage2Root

    chmod u+x ./bin/magento || _die "Unable to add executable permission on ./bin/magento."

    ## @todo find approach
    #find ./var ./pub/static ./pub/media ./app/etc -type f -exec chmod g+w {} \;
    #find ./var ./pub/static ./pub/media ./app/etc -type d -exec chmod g+ws {} \;

    chmod -R 777 ./var ./pub/static ./pub/media ./app/etc || _die "Unable to execute writable permission on files (./var ./pub/static ./pub/media ./app/etc)."

    if [[ -d './generated' ]]; then
        chmod -R 777 ./generated || _die "Unable to execute writable permission on files (./generated)."
    fi

    # @todo handle for multiple OS
    if ! _isOs 'darwin'; then
        chown -R www-data:www-data ./ || _die "Couldn't change ownership of files."
    fi
}

function verifyCurrentDirIsMage2Root()
{
    if [[ ! -f './bin/magento' ]] && [[ ! -f './app/etc/di.xml' ]]; then
        _die "Current directory is not Magento2 root."
    fi
}

function checkCmdDependencies()
{
    local _dependencies=(
      php
      composer
      mysql
      mysqladmin
      git
      wget
      cat
      basename
      tar
      gunzip
      mkdir
      cp
      mv
      rm
      chown
      chmod
      date
      find
      awk
    )

    for cmd in "${_dependencies[@]}"
    do
        hash "${cmd}" &>/dev/null || _die "'${cmd}' command not found."
    done;
}

function checkMage2Dependencies()
{
    #@todo
    local _dependencies=()
}

function printSuccessMessage()
{
    _success "Magento2 Installation Completed!"

    echo "################################################################"
    echo ""
    echo " >> Magento Version          : ${M2_EDITION} (${M2_VERSION})"
    echo " >> Installation Dir         : ${INSTALL_DIR}"

    echo ""
    echo " >> Store Url            : $BASE_URL"
    echo " >> Admin Url            : $BASE_URL$BACKEND_FRONTNAME"
    echo " >> Admin Username       : $ADMIN_USER"
    echo " >> Admin Password       : $ADMIN_PASSWORD"

    echo ""
    echo "################################################################"
    _printPoweredBy

}

################################################################################
# Main
################################################################################
export LC_CTYPE=C
export LANG=C

DEBUG=0
_debug set -x
VERSION="0.1.0"

# Defaults
CURRENT_DIR=$(basename "$(pwd)")
INSTALL_DIR=$(pwd)
DOWNLOAD_DIR=/tmp
INSTALL_SOURCE='tar'
SOURCE_PATH=
M2_EDITION='community'
M2_VERSION=
M2_SETUP_MODE=developer
CREATE_VIRTUAL_HOST=0

INSTALL_SAMPLE_DATA=0

# setup:install Settings
DB_HOST=localhost
DB_USER=root
LANGUAGE='en_US'
CURRENCY='USD'
TIMEZONE='America/Chicago'
SESSION_SAVE='db' #files

# @todo add option from ~/.mage2_installer.conf
# Admin Settings
BACKEND_FRONTNAME="admin_$(genAdminFrontname)"
ADMIN_FIRSTNAME='John'
ADMIN_LASTNAME='Doe'
ADMIN_EMAIL='admin@example.com'
ADMIN_USER='admin'
ADMIN_PASSWORD=$(genRandomPassword)

function main()
{
    checkCmdDependencies

    [[ $# -lt 1 ]] && _printUsage

    # @todo load config from ~/.mage2_installer.conf directory
    # loadConfigFile

    processArgs "$@"

    # @todo check Magento2 dependencies
    #checkMage2Dependencies

    if [[ "$INSTALL_SOURCE" = 'tar' ]]; then
        installFromTar
    fi

    printSuccessMessage

    exit 0
}

main "$@"

_debug set +x
