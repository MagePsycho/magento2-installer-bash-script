# Simplistic Magento 2 Installer

This bash script helps you to quickly install Magento2 from different sources (`tar`, `composer` etc.) with sample data for development purpose.

## INSTALL
You can simply download the script file and give the executable permission.
```
curl -0 https://raw.githubusercontent.com/MagePsycho/magento2-installer-bash-script/master/src/m2-installer.sh -o m2-installer.sh
chmod +x m2-installer.sh
```

To make it a system-wide command (preferred)
```
sudo mv m2-installer.sh /usr/local/bin/m2-installer
```
OR
```
mv m2-installer.sh ~/bin/m2-installer
```
*Make sure your `$HOME/bin` folder is in executable path*

## USAGE
### To display help
```
m2-installer --help
```

![Magento 2 Installer Help](https://github.com/MagePsycho/magento2-installer-bash-script/raw/master/docs/magento2-installer-bash-script-help-v0.1.3.png "Magento2 Installer Help")

### To install Magento CE v2.4.6 (with sample data)
```
m2-installer --version=2.4.6 --base-url=magento246.test --install-sample-data --db-user=root --db-pass=pass --db-name=magento246
```
- `--install-sample-data` option is required to install the sample data.

If you want to install via `composer`, you can simply use `--source=composer` option:
```
m2-installer --source=composer --version=2.4.6 --base-url=magento246.test --install-sample-data --db-user=root --db-pass=pass --db-name=magento246
```
*If `--source` option is not passed, default `tar` source is used for downloading.*

**Notes**  
*Since `elasticsearch` is the default search engine since `v2.4.0` onwards. Make sure to install it prior to M2 installation*  

You can explicitly pass `elasticsearch` params as
- `--search-engine` (default: `elasticsearch7`)
- `--elasticsearch-host` (default: `127.0.0.1`)
- `--elasticsearch-port` (default: `9200`)
- `--elasticsearch-index` (default: `magento2`)

Usage example:
```
m2-installer --version=2.4.6 --base-url=magento246.test --db-user=root --db-pass=pass --db-name=magento246 --search-engine=elasticsearch7 --elasticsearch-host=127.0.0.1
```

### To install Magento CE 2.4.6 (without sample data)
```
m2-installer --version=2.4.6 --base-url=magento246.test --db-user=root --db-pass=pass --db-name=magento246
```

### To install Magento with Redis Caching
If you want to use `redis` as session storage, frontend and full-page caching, you have to use the following params:
- `--use-redis-cache` (required)
- `--redis-host` (optional, default: `127.0.0.1`)
- `--redis-port` (optional, default: `6379`)

Usage example:
```
m2-installer --version=2.4.6 --base-url=magento246.test --db-user=root --db-pass=pass --db-name=magento246 --use-redis-cache
m2-installer --version=2.4.6 --base-url=magento246.test --db-user=root --db-pass=pass --db-name=magento246 --use-redis-cache --redis-host=127.0.0.1 --redis-port=6379
# using different hosts for session/full page caching
m2-installer --version=2.4.6 --base-url=magento246.test --db-user=root --db-pass=pass --db-name=magento246 --use-redis-cache --redis-session-host=127.0.0.1 --redis-default-host=127.0.0.1 --redis-fullpage-host=127.0.0.1
```

### Use of `--force` option
Use `--force` option, if you want to
- Skip the installation wizard/confirmation
- Clean up the directory prior installation

Usage example:
```
m2-installer --version=2.4.6 --base-url=magento246.test --db-user=root --db-pass=pass --db-name=magento246 --force
```

### Use of config files 
If you repeatedly install Magento on your development machine, it is recommended to use the config file in one of the following locations:
1. `~/.m2-installer.conf` - `$HOME` directory (*global scope*)
1. `./.m2-installer.conf` - project directory (*local/project scope*)

*You can copy the sample config provided in the repo `.m2-installer.conf.dist` to the desired location*
```
curl -0 https://raw.githubusercontent.com/MagePsycho/magento2-installer-bash-script/master/.m2-installer.conf.dist -o .m2-installer.conf

# cp .m2-installer.conf.dist ~/.m2-installer.conf
# OR
# cp .m2-installer.conf.dist ./.m2-installer.conf
```

And edit `.m2-installer.conf` config file as
```
# Binary Settings
BIN_COMPOSER="composer"
BIN_PHP="php"

# Web Settings
#PROJECT_NAME=
USE_SECURE=1
LANGUAGE='en_US'
CURRENCY='USD'
TIMEZONE='America/Chicago'

# Storage Settings
# files|redis
SESSION_SAVE='redis'
CACHING_TYPE=redis

# Admin Settings
BACKEND_FRONTNAME="backend"
ADMIN_FIRSTNAME='John'
ADMIN_LASTNAME='Doe'
ADMIN_EMAIL='admin@example.com'
ADMIN_USER='admin'
ADMIN_PASSWORD=$(genRandomPassword)

# DB Settings
DB_HOST=localhost
DB_NAME="${PROJECT_NAME}"
DB_USER=root
DB_PASS=root

# Elasticsearch
SEARCH_ENGINE='elasticsearch7'
ELASTICSEARCH_HOST='127.0.0.1'
ELASTICSEARCH_PORT=9200
ELASTICSEARCH_INDEX_PREFIX="${PROJECT_NAME}_"

# Redis
REDIS_HOST='127.0.0.1'
REDIS_PORT=6379
#REDIS_PREFIX="${PROJECT_NAME}_"
REDIS_SESSION_HOST="$REDIS_HOST"
REDIS_SESSION_PORT="$REDIS_PORT"
REDIS_DEFAULT_HOST="$REDIS_HOST"
REDIS_DEFAULT_PORT="$REDIS_PORT"
REDIS_FULLPAGE_HOST="$REDIS_HOST"
REDIS_FULLPAGE_PORT="$REDIS_PORT"
```

Now you can install Magento 2 simply as:
```
./m2-installer.sh --version=2.4.6 --base-url=magento246.test --use-secure --force
```

### To update the script
```
m2-installer --self-update
```
*Note: This option will only work for version > 0.1.2*

### BONUS 1
You can use this script to quickly install the Magento in your beloved [warden](https://github.com/davidalger/warden) environment
```
cd /path/to/warden/m2/project
warden shell
```
After login to the container, you can download the script (as mentioned above) and install Magento as
```
# With sample data
m2-installer --version=2.4.6 --install-sample-data --use-secure --base-url=app.<project>.test --db-host=<project>_db_1 --db-user=magento --db-pass=magento --db-name=magento --elasticsearch-host=<project>_elasticsearch_1 --use-redis-cache --redis-host=<project>_redis_1 --force

# Without sample data
m2-installer --version=2.4.6 --use-secure --base-url=app.<project>.test --db-host=<project>_db_1 --db-user=magento --db-pass=magento --db-name=magento --elasticsearch-host=<project>_elasticsearch_1 --use-redis-cache --redis-host=<project>_redis_1 --force
```

## BONUS 2
After installation, you can create virtual host with this FREE bash script - 
https://github.com/MagePsycho/nginx-virtual-host-bash-script
```
sudo vhost-nginx --domain=magento246.test --app=magento2
```

## RoadMap
 - [X] Support of installation parameters via config files (`~/.m2-installer.conf` or `./.m2-installer.conf`)
 - [ ] Support multiple compression types (`.gz`, `.zip`, `.tar.bz2`)
 - [ ] Option to install Magento 2 Enterprise Edition
 - [X] Option to install via composer
 - [ ] Option to install via git clone
 - [ ] Option to check system readiness (PHP & it's extensions, MySQL, Nginx/Apache)
 - [X] Option to create virtual host (nginx)
 - [ ] Option to create crontab settings
 - [ ] Option to migrate with local codebase + database
