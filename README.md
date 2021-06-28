Composer Global Updater
=======================

![logo](composer-global-update.svg?raw=true)

 *Prepare Autoloader for PHP Application installed from package 
 *Update PHP libraries in /usr/share/* or /usr/lib/* using composer

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


How to make compatible packages
===============================


Libraries
---------

    1. use **deb** as vendorname for your library
    2. Put composer.json into /usr/share/php///LibraryDir///
    3. into library package's postinst put **composer-global-update deb/libname


Applications
------------

    1. Put composer.json into /usr/lib///AppName///
    2. into application package's postinst put **composer-debian AppName**
    3. use /var/lib/composer/AppName/autoloader.php



Example of composer.json:

```json
{
  "name": "vitexsoftware/multi-abraflexi-setup",
  "description": "Tool used to setup AbraFlexi multiinstance",
  "version": "1.1",
  "type": "project",
  "require": {
    "deb/ease-bootstrap4-widgets-abraflexi": "*",
    "deb/ease-bootstrap4-widgets": "*",
    "deb/ease-fluentpdo": "*"
  },
  "license": "MIT",
  "authors": [
    {
      "name": "Vítězslav Dvořák",
      "email": "info@vitexsoftware.cz"
    }
  ],
  "config": {
    "vendor-dir": "/var/lib/multi-abraflexi-setup"
  },
  "minimum-stability": "dev",
  "autoload": {
    "psr-4": {
      "AbraFlexi\\MultiSetup\\": "AbraFlexi",
      "AbraFlexi\\MultiSetup\\Ui\\": "AbraFlexi/Ui"
    }
  },
  "repositories": [
    {
      "type": "path",
      "url": "/usr/share/php/EaseCore/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/EaseHtml/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/AbraFlexi/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/EaseBricks/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/EaseTWB4/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/EaseFluentPDO/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/AbraFlexiBricks/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/EaseTWB4Widgets/"
    },
    {
      "type": "path",
      "url": "/usr/share/php/EaseTWB4WidgetsAbraFlexi/"
    }
  ]
}

```


