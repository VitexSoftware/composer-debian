Composer Global Updater
=======================

![logo](composer-global-update.svg?raw=true)

Update PHP libraries in /usr/share/* or /usr/lib/* using composer

Installation
------------

```shell
sudo apt install lsb-release wget
echo "deb http://repo.vitexsoftware.cz $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/vitexsoftware.list
sudo wget -O /etc/apt/trusted.gpg.d/vitexsoftware.gpg http://repo.vitexsoftware.cz/keyring.gpg
sudo apt update
sudo apt install composer-global-update
        
```

Usage
-----

Update all dependencies
``` bash
 $ composer-global-update
```

Update only dependencies with keyword within its name
``` bash
 $ composer-global-update nette
```


