# Simplistic Magento 2 Installer

This bash script helps you to install Magento2 from different sources (tar, composer etc.) with sample data.


## INSTALL
You can simply download the script file and give the executable permission.
```
curl -0 https://raw.githubusercontent.com/MagePsycho/magento2-installer-bash-script/master/src/magento2-installer.sh -o mage2-installer.sh
chmod +x mage2-installer.sh
```

To make it system wide command
```
sudo mv mage2-installer.sh /usr/local/bin/mage2-installer
```
OR
```
mv mage2-installer.sh ~/bin/mage2-installer
```
*Make sure your `$HOME/bin` folder is in executable path*

## USAGE
### To display help
```
./mage2-installer.sh --help
```

### To install Magento CE 2.3.1 (with sample data)
```
./mage2-installer.sh --version=2.3.1 --base-url=magento231ce.test --install-sample-data --db-user=root --db-pass=pass --db-name=magento231ce
```

`--source` option is optional which defaults value to `tar` .
If you want to install via composer, you can use `--source=composer` option
```
./mage2-installer.sh --source=composer --version=2.3.1 --base-url=magento231ce.test --install-sample-data --db-user=root --db-pass=pass --db-name=magento231ce
```

### To install Magento CE 2.3.1 (without sample data)
```
./mage2-installer.sh --version=2.3.1 --base-url=magento231ce.test --db-user=root --db-pass=pass --db-name=magento231ce
```

## BONUS
After installation, you can create virtual host with this FREE bash script - 
https://github.com/MagePsycho/nginx-virtual-host-bash-script
```
sudo ./vhost-nginx.sh --domain=magento231ce.test --app=magento2 --root-dir=/path/to/magento2
```

## Screenshots
![Mage2Backup Help](https://github.com/MagePsycho/magento2-installer-bash-script/raw/master/docs/magento2-installer-bash-script-help.png "Magento2 Installer Help")
Screentshot - Magento2 Installer Help

## RoadMap
 - [ ] Support multiple compression types (`.gz`, `.zip`, `.tar.bz2`)
 - [ ] Option to install Magento 2 Enterprise Edition
 - [X] Option to install via composer
 - [ ] Option to install via git clone
 - [ ] Option to check system readiness (PHP & it's extensions, MySQL, Nginx/Apache)
 - [X] Option to create virtual host (nginx)
 - [ ] Option to create crontab settings
 - [ ] Option to migrate with local codebase + database
