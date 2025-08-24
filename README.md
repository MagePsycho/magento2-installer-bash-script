# 🚀 Simplistic Magento 2 Installer

This **bash script** helps you quickly install **Magento 2** from different sources (`tar`, `composer`, etc.) with optional sample data — perfect for development setups.

---

## 📥 Installation

Download the script and make it executable:

```bash
curl -O https://raw.githubusercontent.com/MagePsycho/magento2-installer-bash-script/master/src/m2-installer.sh
chmod +x m2-installer.sh
```

To make it a system-wide command (preferred):

```bash
sudo mv m2-installer.sh /usr/local/bin/m2-installer
```

Or for user scope:

```bash
mv m2-installer.sh ~/bin/m2-installer
```

> ⚠️ Make sure your `$HOME/bin` folder is in your `$PATH`.

---

## 🛠 Usage

### Show help
```bash
m2-installer --help
```

![Magento 2 Installer Help](https://github.com/MagePsycho/magento2-installer-bash-script/raw/master/docs/magento2-installer-bash-script-help-v0.1.3.png "Magento2 Installer Help")

---

### Install Magento CE 2.4.8 (with sample data)

```bash
m2-installer --version=2.4.8 --base-url=magento248.test   --install-sample-data --db-user=root --db-pass=pass --db-name=magento248
```

> `--install-sample-data` is required to include sample data.

Install via Composer:

```bash
m2-installer --source=composer --version=2.4.8 --base-url=magento248.test   --install-sample-data --db-user=root --db-pass=pass --db-name=magento248
```

*If `--source` is not passed, `tar` is used by default.*

---

## 🔍 Search Engine Configuration

Magento >= 2.4.0 defaults to **Elasticsearch**, and >= 2.4.8 prefers **OpenSearch**.  
Make sure you have the right service installed before running the installer.

### Elasticsearch options
- `--search-engine` (default: `elasticsearch7`)
- `--elasticsearch-host` (default: `127.0.0.1`)
- `--elasticsearch-port` (default: `9200`)
- `--elasticsearch-index` (default: `magento2`)

### OpenSearch options
- `--search-engine` (default: `opensearch`)
- `--opensearch-host` (default: `127.0.0.1`)
- `--opensearch-port` (default: `9200`)
- `--opensearch-index` (default: `magento2`)

**Examples:**
```bash
m2-installer --version=2.4.7 --base-url=magento247.test   --db-user=root --db-pass=pass --db-name=magento247   --search-engine=elasticsearch7 --elasticsearch-host=127.0.0.1
```

```bash
m2-installer --version=2.4.8 --base-url=magento248.test   --db-user=root --db-pass=pass --db-name=magento248   --search-engine=opensearch --opensearch-host=127.0.0.1
```

---

## ⚡ Redis Caching Support

To use `redis` for sessions, frontend, and full-page cache:

- `--use-redis-cache` (required)
- `--redis-host` (default: `127.0.0.1`)
- `--redis-port` (default: `6379`)

**Example:**
```bash
m2-installer --version=2.4.8 --base-url=magento248.test   --db-user=root --db-pass=pass --db-name=magento248 --use-redis-cache
```

---

## 🔄 Force Install

Skip confirmation prompts and clean the directory before installation:

```bash
m2-installer --version=2.4.8 --base-url=magento248.test   --db-user=root --db-pass=pass --db-name=magento248 --force
```

---

## ⚙️ Config Files

Instead of passing flags every time, you can use a config file:

1. **Global:** `~/.m2-installer.conf`
2. **Local/project:** `./.m2-installer.conf`

Copy the sample config:
```bash
curl -O https://raw.githubusercontent.com/MagePsycho/magento2-installer-bash-script/master/.m2-installer.conf.dist
cp .m2-installer.conf.dist ~/.m2-installer.conf
```

Edit to set defaults like DB credentials, search engine, Redis, etc.

Then run simply:
```bash
m2-installer --version=2.4.8 --base-url=magento248.test --use-secure --force
```

---

## 🔧 Updating the Script

```bash
m2-installer --self-update
```

> Works for version `> 0.1.2`

---

## 🎁 Bonus

### 1. Use with [Warden](https://github.com/davidalger/warden)
```bash
cd /path/to/warden/m2/project
warden shell
```

Inside the container:

```bash
m2-installer --version=2.4.8 --install-sample-data --use-secure   --base-url=app.<project>.test --db-host=<project>_db_1   --db-user=magento --db-pass=magento --db-name=magento   --elasticsearch-host=<project>_elasticsearch_1 --use-redis-cache   --redis-host=<project>_redis_1 --force
```

### 2. Create a Virtual Host

Use this free bash script: [nginx-virtual-host-bash-script](https://github.com/MagePsycho/nginx-virtual-host-bash-script)

```bash
sudo vhost-nginx --domain=magento248.test --app=magento2
```

---

## 🗺️ Roadmap

- [X] Config files support (`~/.m2-installer.conf` or `./.m2-installer.conf`)
- [X] Install via Composer
- [X] Create virtual host (nginx)
- [ ] Multiple compression types (`.gz`, `.zip`, `.tar.bz2`)
- [ ] Install Magento 2 EE
- [ ] Install via Git clone
- [ ] System readiness checks (PHP, MySQL, Nginx/Apache, etc.)
- [ ] Crontab setup
- [ ] Migration with local codebase + DB

---

## 🙌 Credits
Developed & maintained by **[MagePsycho](https://www.magepsycho.com)**  
Licensed under [OSL 3.0](http://opensource.org/licenses/osl-3.0.php)
