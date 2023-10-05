#!/usr/bin/env bash

#
# Script to install Magento2
#
# @author   Raj KB <magepsycho@gmail.com>
# @website  https://www.magepsycho.com
# @version  0.1.3

# Exit on error. Append "|| true" if you expect an error.
#set -o errexit
# Exit on error inside any functions or subshells.
#set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
#set -o nounset
# Catch the error in case mysqldump fails (but gzip succeeds) in `mysqldump | gzip`
#set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

################################################################################
# CORE FUNCTIONS - Do not edit
################################################################################
#
# VARIABLES
#
_bold=$(tput bold)
_italic="\e[3m"
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)

_black=$(tput setaf 0)
_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)
_white=$(tput setaf 7)

#
# HEADERS & LOGGING
#
function _debug()
{
    if [[ "$DEBUG" -eq 1 ]]; then
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
function _seekValue()
{
    local _msg="${_green}$1${_reset}"
    local _readDefaultValue="$2"
    READVALUE=
    if [[ "${_readDefaultValue}" ]]; then
        _msg="${_msg} ${_white}[${_reset}${_green}${_readDefaultValue}${_reset}${_white}]${_reset}"
    else
        _msg="${_msg} ${_white}[${_reset} ${_white}]${_reset}"
    fi

    _msg="${_msg}: "
    printf "%s\n➜ " "$_msg"
    read READVALUE

    # Inline input
    #_msg="${_msg}: "
    #read -r -p "$_msg" READVALUE

    if [[ $READVALUE = [Nn] ]]; then
        READVALUE=''
        return
    fi
    if [[ -z "${READVALUE}" ]] && [[ "${_readDefaultValue}" ]]; then
        READVALUE=${_readDefaultValue}
    fi
}

function _seekConfirmation()
{
    read -r -p "${_bold}${1:-Are you sure? [y/N]}${_reset} " response
    case "$response" in
        [yY][eE][sS]|[yY])
            retval=0
            ;;
        *)
            retval=1
            ;;
    esac
    return $retval
}

# Test whether the result of an 'ask' is a confirmation
function _isConfirmed()
{
    [[ "$REPLY" =~ ^[Yy]$ ]]
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

function _isOsDebian()
{
    [[ -f /etc/debian_version ]]
}

function _checkRootUser()
{
    #if [ "$(id -u)" != "0" ]; then
    if [[ "$(whoami)" != 'root' ]]; then
        echo "You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
    fi
}

function _semVerToInt() {
  local _semVer
  _semVer="${1:?No version number supplied}"
  _semVer="${_semVer//[^0-9.]/}"
  # shellcheck disable=SC2086
  set -- ${_semVer//./ }
  printf -- '%d%02d%02d' "${1}" "${2:-0}" "${3:-0}"
}

function _selfUpdate()
{
    local _tmpFile _newVersion
    _tmpFile=$(mktemp -p "" "XXXXX.sh")
    curl -s -L "$SCRIPT_URL" > "$_tmpFile" || _die "Couldn't download the file"
    _newVersion=$(awk -F'[="]' '/^VERSION=/{print $3}' "$_tmpFile")
    if [[ "$(_semVerToInt $VERSION)" < "$(_semVerToInt $_newVersion)" ]]; then
        printf "Updating script \e[31;1m%s\e[0m -> \e[32;1m%s\e[0m\n" "$VERSION" "$_newVersion"
        printf "(Run command: %s --version to check the version)" "$(basename "$0")"
        mv -v "$_tmpFile" "$ABS_SCRIPT_PATH" || _die "Unable to update the script"
        # rm "$_tmpFile" || _die "Unable to clean the temp file: $_tmpFile"
        # @todo make use of trap
        # trap "rm -f $_tmpFile" EXIT
    else
         _arrow "Already the latest version."
    fi
    exit 1
}

function _printPoweredBy()
{
    local _mpAscii
    _mpAscii='
   __  ___              ___               __
  /  |/  /__ ____ ____ / _ \___ __ ______/ /  ___
 / /|_/ / _ `/ _ `/ -_) ___(_-</ // / __/ _ \/ _ \
/_/  /_/\_,_/\_, /\__/_/  /___/\_, /\__/_//_/\___/
            /___/             /___/
'
    cat <<EOF
${_green}
Powered By:
$_mpAscii

 >> Store: ${_reset}${_underline}${_blue}https://www.magepsycho.com${_reset}${_reset}${_green}
 >> Blog:  ${_reset}${_underline}${_blue}https://blog.magepsycho.com${_reset}${_reset}${_green}

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
        --source                    Installation source (Options: tar, composer, Default: tar)
        --edition                   Magento2 edition (Default: community)
        --version                   Magento2 version
                                    Refer - https://github.com/magento/magento2/releases
        --install-dir               Magento2 installation directory (Default: Current)
        --base-url                  Base URL
        --install-sample-data       Install sample data (Default: disabled)
        --setup-mode                Setup Mode (Default: developer)

        --db-host                   DB host (Default: localhost)
        --db-user                   DB user (Default: root)
        --db-pass                   DB pass
        --db-name                   DB name
        --db-prefix                 DB prefix

        --use-secure                Enable https URLs (Default: disabled)

        --search-engine             Search engine, used for  v2.4.0 or later (Default: elasticsearch7)
        --elasticsearch-host        Elasticsearch host (Default: 127.0.0.1)
        --elasticsearch-port        Elasticsearch port (Default: 9200)
        --elasticsearch-index       Elasticsearch index prefix (Default: magento2)

        --use-redis-cache           Enable Redis cache for session, frontend & full-page (Default: disabled)
        --redis-host                Redis host (Default: 127.0.0.1)
        --redis-port                Redis port (Default: 6379)

        --admin-firstname           Admin firstname (Default: John)
        --admin-lastname            Admin lastname (Default: Doe)
        --admin-email               Admin email (Default: admin@example.com)
        --admin-user                Admin user (Default: admin)
        --admin-password            Admin password

        --language                  Language (Default: en_US)
        --currency                  Currency (Default: USD)
        --timezone                  Timezone (Default: America/Chicago)

        --force                     Forcefully drops the DB if exists & cleans up the installation directory

        -h,     --help              Display this help and exit
        -su,    --update            Self-update the script from Git repository
                --self-update

    Examples:
        $(basename "$0") [--source=...] --version=... --base-url=... --install-sample-data --db-user=... --db-pass=... --db-name=...
        $(basename "$0") [--source=...] --version=... --base-url=... --install-sample-data --db-user=... --db-pass=... --db-name=... --use-redis-cache --redis-host=...
        $(basename "$0") [--source=...] --version=... --base-url=... --install-sample-data --db-user=... --db-pass=... --db-name=... --elasticsearch-host=...
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
            --search-engine=*)
                SEARCH_ENGINE="${arg#*=}"
            ;;
            --elasticsearch-host=*)
                ELASTICSEARCH_HOST="${arg#*=}"
            ;;
            --elasticsearch-port=*)
                ELASTICSEARCH_PORT="${arg#*=}"
            ;;
            --elasticsearch-index=*)
                ELASTICSEARCH_INDEX_PREFIX="${arg#*=}"
            ;;
            --backend-frontName=*)
                BACKEND_FRONTNAME="${arg#*=}"
            ;;
            --use-redis-cache)
                CACHING_TYPE="redis"
                SESSION_SAVE="redis"
            ;;
            --redis-host=*)
                REDIS_HOST="${arg#*=}"
            ;;
            --redis-port=*)
                REDIS_PORT="${arg#*=}"
            ;;
            --redis-session-host=*)
                REDIS_SESSION_HOST="${arg#*=}"
            ;;
            --redis-session-port=*)
                REDIS_SESSION_PORT="${arg#*=}"
            ;;
            --redis-default-host=*)
                REDIS_DEFAULT_HOST="${arg#*=}"
            ;;
            --redis-default-port=*)
                REDIS_DEFAULT_PORT="${arg#*=}"
            ;;
            --redis-fullpage-host=*)
                REDIS_FULLPAGE_HOST="${arg#*=}"
            ;;
            --redis-fullpage-port=*)
                REDIS_FULLPAGE_PORT="${arg#*=}"
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
            --use-secure)
                USE_SECURE=1
            ;;
            --force)
                FORCE=1
            ;;
            --debug)
                DEBUG=1
                set -o xtrace
            ;;
            -u|--update|--self-update)
                _selfUpdate
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

    if [[ "$INSTALL_SOURCE" != @(tar|composer) ]]; then
        _error "Install source must be one of tar|composer."
    fi

    if [[ "$M2_VERSION" ]] && [[ "$INSTALL_SOURCE" == 'tar' ]]; then
        prepareM2GitTarUrl
        if ! $(validateUrl $SOURCE_PATH); then
            _error "Magento2 tar with version '${M2_VERSION}' doesn't exist."
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi

    # Prepare & validate installation directory
    if [[ "$INSTALL_DIR" ]]; then
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

    if [[ "$DB_PASS" ]] && [[ "$DB_NAME" ]]; then
        "$BIN_MYSQL" -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e exit
        if [[ $? -eq 1  ]]; then
            _error "Unable to connect the database. Please re-check the --db-* parameters."
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi

    [[ "$ERROR_COUNT" -gt 0 ]] && exit 1
}

function validateUrl()
{
    if command -v curl >/dev/null 2>&1; then
        # @todo find appropriate command in `curl`
        return 0
    else
        if [[ `wget -S --no-check-certificate --secure-protocol=TLSv1_2 --spider $1 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
            # 0 = true
            return 0
        else
            # 1 = false
            return 1
        fi
    fi
}

function sanitizeArgs()
{
    # remove trailing /
    if [[ "$INSTALL_DIR" ]]; then
        INSTALL_DIR="${INSTALL_DIR%/}"
    fi
    if [[ "$DOWNLOAD_DIR" ]]; then
        DOWNLOAD_DIR="${DOWNLOAD_DIR%/}"
    fi
}

function prepareDownloadDir()
{
    DOWNLOAD_DIR=/tmp
}

function prepareBaseUrl()
{
    local _httpProtocol="http"
    if [[ "$USE_SECURE" -eq 1 ]]; then
        _httpProtocol="https"
    fi
    BASE_URL="${_httpProtocol}://$(getDomainFromUrl)/"
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
    echo $(cat /dev/urandom | env LC_ALL=C tr -dc 'a-z0-9' | fold -w 6 | head -n 1)
}

function genRandomPassword()
{
    echo $(cat /dev/urandom | env LC_ALL=C tr -dc '_a-zAZ_0-9&$@%' | fold -w 8 | head -n 1)
}

function composerInstall()
{
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR" || _die "Couldn't change directory to : ${INSTALL_DIR}."

    "$BIN_COMPOSER" create-project --repository=https://repo.magento.com/ magento/project-community-edition:"${M2_VERSION}" .
    #composer create-project --repository=https://repo.magento.com/ magento/project-enterprise-edition:"${M2_VERSION}" .

    if [[ ! -f ./nginx.conf ]]; then
        cp ./nginx.conf.sample ./nginx.conf
    fi
    verifyCurrentDirIsMage2Root

    beforeInstall

    # if db already exists, throws SQL error
    createDbIfNotExists
    setFilesystemPermission
    installMagento

    if [[ "$INSTALL_SAMPLE_DATA" -eq 1 ]]; then
        installSampleData
    fi

    afterInstall
}

function tarInstall()
{
    # Check Magento dependencies
    # @todo

    # STEP 1 - Prepare & Download file
    M2_ARCHIVE_FILE="m2-${M2_EDITION}-${M2_VERSION}.tar.gz"
    M2_ARCHIVE_PATH="${DOWNLOAD_DIR}"/"${M2_ARCHIVE_FILE}"
    _arrow "Downloading Magento ${M2_VERSION}..."
    if [[ ! -f "$M2_ARCHIVE_PATH" ]]; then
        if command -v curl >/dev/null 2>&1; then
            curl -LJ -0 "$SOURCE_PATH" -o "${M2_ARCHIVE_PATH}" || _die "Download failed."
        else
            wget --no-check-certificate --secure-protocol=TLSv1_2 "$SOURCE_PATH" -O "${M2_ARCHIVE_PATH}" || _die "Download failed."
        fi
        # save for future reference @todo
    else
        _note " Skipped downloading(${M2_ARCHIVE_FILE} already exists)"
    fi

    # STEP 2 - Prepare & Install downloaded file
    mkdir -p "$INSTALL_DIR"
    ###cp "$M2_ARCHIVE_PATH" "$INSTALL_DIR" || _die "Cannot copy files to install directory."

    # Clean up installation directory
    if [[ "$FORCE" -eq 1 ]] && [[ -f "${INSTALL_DIR}/bin/magento" ]] && [[ -f "${INSTALL_DIR}/app/etc/di.xml" ]]; then
        _arrow "Cleaning up the installation directory..."
        rm -rf "$INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
    fi

    _arrow "Extracting files to ${INSTALL_DIR}..."
    tar -zxf "$M2_ARCHIVE_PATH" -C "${INSTALL_DIR}" || _die "Couldn't extract file: ${M2_ARCHIVE_PATH}."

    cd "$INSTALL_DIR" || _die "Couldn't change directory to : ${INSTALL_DIR}."

    # Finally move all the files from sub-folder to the www dir
    mv "magento2-$M2_VERSION"/{.[!.],}* ./
    if [[ $? -ne 0 ]]; then
        cp -rf "magento2-$M2_VERSION"/{.[!.],}* ./
        rm -rf "magento2-$M2_VERSION"
    fi

    if [[ ! -f ./nginx.conf ]]; then
        cp ./nginx.conf.sample ./nginx.conf
    fi
    verifyCurrentDirIsMage2Root

    beforeInstall

    # if db already exists, throws SQL error
    createDbIfNotExists

    setFilesystemPermission

    rm -rf "magento2-${M2_VERSION}"/

    _arrow "Running Composer..."
    "$BIN_COMPOSER" install || _die "'composer install' command failed."

    installMagento

    if [[ "$INSTALL_SAMPLE_DATA" -eq 1 ]]; then
        installSampleData
    fi

    afterInstall
}

function createDbIfNotExists()
{
    if ! "$BIN_MYSQL" -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "USE ${DB_NAME}"; then
        _arrow "Creating database ${DB_NAME}..."
        "$BIN_MYSQL" -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}" || _die "Couldn't create database: ${DB_NAME}."
    else
        _arrow "Skipping: database ${DB_NAME} already exists..."
    fi
}

function dropDb()
{
    _arrow "Dropping database ${DB_NAME}..."
    "$BIN_MYSQL" -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "DROP DATABASE IF EXISTS $DB_NAME" || _die "Couldn't drop database: ${DB_NAME}."
}

function initUserInputWizard()
{
    _note "Press [enter] if you want to use the default value."

    _seekValue "Enter Magento Edition" "${M2_EDITION}"
    M2_EDITION=${READVALUE}

    _seekValue "Enter Magento Version" "${M2_VERSION}"
    M2_VERSION=${READVALUE}

    _seekValue "Install Sample Data" "${INSTALL_SAMPLE_DATA}"
    INSTALL_SAMPLE_DATA=${READVALUE}

    _seekValue "Enter Base URL" "${BASE_URL}"
    BASE_URL=${READVALUE}

    _seekValue "Use Secure" "${USE_SECURE}"
    USE_SECURE=${READVALUE}

    _seekValue "Enter DB Host" "${DB_HOST}"
    DB_HOST=${READVALUE}

    _seekValue "Enter DB User" "${DB_USER}"
    DB_USER=${READVALUE}

    _seekValue "Enter DB Pass" "${DB_PASS}"
    DB_PASS=${READVALUE}

    if [[ "$(_semVerToInt ${M2_VERSION})" -ge 240 ]]; then
        _seekValue "Enter Search Engine" "${SEARCH_ENGINE}"
        SEARCH_ENGINE=${READVALUE}

        _seekValue "Enter Elasticsearch Host" "${ELASTICSEARCH_HOST}"
        ELASTICSEARCH_HOST=${READVALUE}

        _seekValue "Enter Elasticsearch Port" "${ELASTICSEARCH_PORT}"
        ELASTICSEARCH_PORT=${READVALUE}

        _seekValue "Enter Elasticsearch Index Prefix" "${ELASTICSEARCH_INDEX_PREFIX}"
        ELASTICSEARCH_INDEX_PREFIX=${READVALUE}
    fi

    if [[ "$CACHING_TYPE" = "redis" ]]; then
        _seekValue "Enter Redis Host" "${REDIS_HOST}"
        REDIS_HOST=${READVALUE}

        _seekValue "Enter Redis Port" "${REDIS_PORT}"
        REDIS_PORT=${READVALUE}
    fi
}

function installMagento()
{
    _arrow "Installing Magento2..."
    prepareBaseUrl

    # REF - https://devdocs.magento.com/guides/v2.4/install-gde/install/cli/install-cli.html
    local _installOpts=(
      "--base-url=${BASE_URL}"
      "--db-host=${DB_HOST}"
      "--db-name=${DB_NAME}"
      "--db-user=${DB_USER}"
      "--db-password=${DB_PASS}"
      "--backend-frontname=${BACKEND_FRONTNAME}"
      "--admin-firstname=${ADMIN_FIRSTNAME}"
      "--admin-lastname=${ADMIN_LASTNAME}"
      "--admin-email=${ADMIN_EMAIL}"
      "--admin-user=${ADMIN_USER}"
      "--admin-password=${ADMIN_PASSWORD}"
      "--language=${LANGUAGE}"
      "--currency=${CURRENCY}"
      "--timezone=${TIMEZONE}"
      "--use-rewrites=1"
      "--cleanup-database"
    )

    # Configure Elasticsearch
    if [[ "$(_semVerToInt ${M2_VERSION})" -ge 240 ]]; then
      _installOpts+=(
        "--search-engine=${SEARCH_ENGINE}"
        "--elasticsearch-host=${ELASTICSEARCH_HOST}"
        "--elasticsearch-port=${ELASTICSEARCH_PORT}"
        "--elasticsearch-index-prefix=${ELASTICSEARCH_INDEX_PREFIX}"
        "--elasticsearch-enable-auth=0"
        "--elasticsearch-timeout=15"
      )
    fi

    if [[ "$CACHING_TYPE" = "redis" ]]; then
      _installOpts+=(
        "--session-save=redis"
        "--session-save-redis-host=${REDIS_SESSION_HOST}"
        "--session-save-redis-port=${REDIS_SESSION_PORT}"
        "--session-save-redis-db=2"
        "--session-save-redis-max-concurrency=20"
        "--cache-backend=redis"
        "--cache-backend-redis-server=${REDIS_DEFAULT_HOST}"
        "--cache-backend-redis-db=0"
        "--cache-backend-redis-port=${REDIS_DEFAULT_PORT}"
        "--page-cache=redis"
        "--page-cache-redis-server=${REDIS_FULLPAGE_HOST}"
        "--page-cache-redis-db=1"
        "--page-cache-redis-port=${REDIS_FULLPAGE_PORT}"
      )
    else
      "--session-save=${SESSION_SAVE}"
    fi

    if [[ "$USE_SECURE" -eq 1 ]]; then
      _installOpts+=(
        "--use-secure=1"
        "--base-url-secure=${BASE_URL}"
        "--use-secure-admin=1"
      )
    fi

    "$BIN_PHP" -d memory_limit=-1 ./bin/magento setup:install "${_installOpts[@]}"
}

function loadConfigFile()
{
    # Load config if exists in home(~/)
    if [[ -f "${HOME}/${CONFIG_FILE}" ]]; then
        source "${HOME}/${CONFIG_FILE}"
    fi

    # Load config if exists in project (./)
    if [[ -f "${INSTALL_DIR}/${CONFIG_FILE}" ]]; then
        source "${INSTALL_DIR}/${CONFIG_FILE}"
    fi
}

function installSampleData()
{
    _arrow "Installing sample data..."

    # "${HOME}/.config/composer/auth.json"
    if [[ -f "${HOME}/.composer/auth.json" ]]; then
        if [[ -d ./var/composer_home ]]; then
            cp "${HOME}/.composer/auth.json" ./var/composer_home/
        fi
    fi

    "$BIN_COMPOSER" config repositories.magento composer https://repo.magento.com

    "$BIN_PHP" -d memory_limit=-1 ./bin/magento sampledata:deploy

    # Run in case of Authentication error
    ###composer update

    "$BIN_PHP" -d memory_limit=-1 ./bin/magento setup:upgrade
}

function beforeInstall()
{
    if [[ "$FORCE" -eq 0 ]]; then
        _arrow "Preparing the installation parameters..."
        initUserInputWizard
    fi
}

function afterInstall()
{
    if [[ "$M2_SETUP_MODE" = 'developer' ]]; then
        _arrow "Setting developer mode..."
        "$BIN_PHP" ./bin/magento deploy:mode:set developer
    fi

    if [[ "$M2_SETUP_MODE" = 'production' ]]; then
        _arrow "Setting production mode..."
        "$BIN_PHP" ./bin/magento deploy:mode:set production
    fi
    setFilesystemPermission
}

function setFilesystemPermission()
{
    _arrow "Setting ownership & permissions..."
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
        if [[ $(whoami) != 'www-data' ]]; then
            sudo chown -R www-data:www-data ./ || _die "Couldn't change ownership of files."
        fi
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
        "$BIN_PHP"
        "$BIN_COMPOSER"
        mysql
        git
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
    local _depMissing
    local _depCounter=0
    for dependency in "${_dependencies[@]}"; do
        if ! command -v "$dependency" >/dev/null 2>&1; then
            _depCounter=$(( _depCounter + 1 ))
            _depMissing="${_depMissing} ${dependency}"
        fi
    done
    if [[ "${_depCounter}" -gt 0 ]]; then
      _die "Could not find the following dependencies:${_depMissing}"
    fi
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
VERSION="0.1.4"

# Defaults
BIN_COMPOSER="composer"
BIN_MYSQL="mysql"
BIN_PHP="php"
PROJECT_NAME=$(basename "$(pwd)")
CURRENT_DIR=$(basename "$(pwd)")
INSTALL_DIR=$(pwd)
DOWNLOAD_DIR=/tmp
CONFIG_FILE=".m2-installer.conf"
INSTALL_SOURCE='tar'
SOURCE_PATH=
M2_EDITION='community'
M2_VERSION=2.4.3
M2_SETUP_MODE=developer
INSTALL_SAMPLE_DATA=0

# setup:install Settings
DB_HOST=localhost
DB_USER=root
LANGUAGE='en_US'
CURRENCY='USD'
TIMEZONE='America/Chicago'
SESSION_SAVE='files'
CACHING_TYPE=

# Admin Settings
#BACKEND_FRONTNAME="admin_$(genAdminFrontname)"
BACKEND_FRONTNAME="backend"
ADMIN_FIRSTNAME='John'
ADMIN_LASTNAME='Doe'
ADMIN_EMAIL='admin@example.com'
ADMIN_USER='admin'
ADMIN_PASSWORD=$(genRandomPassword)

# Elasticsearch
SEARCH_ENGINE='elasticsearch7'
ELASTICSEARCH_HOST='127.0.0.1'
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_INDEX_PREFIX='magento2'

# Redis
REDIS_HOST='127.0.0.1'
REDIS_PORT=6379
REDIS_PREFIX="${PROJECT_NAME}_"
REDIS_SESSION_HOST="$REDIS_HOST"
REDIS_SESSION_PORT="$REDIS_PORT"
REDIS_DEFAULT_HOST="$REDIS_HOST"
REDIS_DEFAULT_PORT="$REDIS_PORT"
REDIS_FULLPAGE_HOST="$REDIS_HOST"
REDIS_FULLPAGE_PORT="$REDIS_PORT"

USE_SECURE=0

FORCE=0

function main()
{
    [[ $# -lt 1 ]] && _printUsage

    loadConfigFile

    checkCmdDependencies

    processArgs "$@"

    # @todo check Magento2 dependencies
    #checkMage2Dependencies

    if [[ "$INSTALL_SOURCE" = 'tar' ]]; then
        tarInstall
    fi

    if [[ "$INSTALL_SOURCE" = 'composer' ]]; then
        composerInstall
    fi

    printSuccessMessage

    exit 0
}

main "$@"

_debug set +x
