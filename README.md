# Simplistic Magento 2 Installer

This bash script helps you to install Magento2 from different sources (`tar`, `composer` etc.) with sample data.


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

![Mage2Backup Help](https://github.com/MagePsycho/magento2-installer-bash-script/raw/master/docs/magento2-installer-bash-script-help.png "Magento2 Installer Help")

### To install Magento CE v2.4.3 (with sample data)
```
./m2-installer --version=2.4.3 --base-url=magento243.test --install-sample-data --db-user=root --db-pass=pass --db-name=magento243
```

*If `--source` option is not passed, default `tar` source is used for downloading.*

If you want to install via `composer`, you can simply use `--source=composer` option:
```
./m2-installer --source=composer --version=2.4.3 --base-url=magento243.test --install-sample-data --db-user=root --db-pass=pass --db-name=magento243
```

#### Notes
Since `elasticsearch` is the default search engine since v2.4.0 onwards. Make sure to install it prior to M2 installation.  

You can explicitly pass `elasticsearch` params as
- `--search-engine` (default: `elasticsearch7`)
- `--elasticsearch-host` (default: `127.0.0.1`)
- `--elasticsearch-port` (default: `9200`)
- `--elasticsearch-index` (default: `magento2`)

Usage example:
```
m2-installer --version=2.4.3 --base-url=magento243.test --db-user=root --db-pass=pass --db-name=magento243 --search-engine=elasticsearch7 --elasticsearch-host=127.0.0.1
```

### To install Magento CE 2.4.3 (without sample data)
```
./m2-installer.sh --version=2.4.3 --base-url=magento243.test --db-user=root --db-pass=pass --db-name=magento243
```

### To install Magento with Redis Caching
If you want to use `redis` as session, frontend and full-page caching, you have to use the following params:
- `--use-redis-cache` (required)
- `--redis-host` (optional, default: `127.0.0.1`)
- `--redis-port` (optional, default: `6379`)

Usage example:
```
./m2-installer.sh --version=2.4.3 --base-url=magento243.test --db-user=root --db-pass=pass --db-name=magento243 --use-redis-cache
```

### Use of `--force` option
Use `--force` option, if you want to
- forcefully drop the database if exists 
- clean up the directory prior installation
- skip the installation inputs as wizard


## BONUS
After installation, you can create virtual host with this FREE bash script - 
https://github.com/MagePsycho/nginx-virtual-host-bash-script
```
sudo ./vhost-nginx.sh --domain=magento243.test --app=magento2
```

## RoadMap
 - [ ] Support of installation parameters via config files (`~/.m2-installer.conf` or `./.m2-installer.conf`)
 - [ ] Support multiple compression types (`.gz`, `.zip`, `.tar.bz2`)
 - [ ] Option to install Magento 2 Enterprise Edition
 - [X] Option to install via composer
 - [ ] Option to install via git clone
 - [ ] Option to check system readiness (PHP & it's extensions, MySQL, Nginx/Apache)
 - [X] Option to create virtual host (nginx)
 - [ ] Option to create crontab settings
 - [ ] Option to migrate with local codebase + database
