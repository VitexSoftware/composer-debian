# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

Repository overview
- Purpose: Debian package that ships shell utilities to manage Composer dependencies for system-installed PHP apps and libraries.
- Primary executables: composer-debian, composer-global-update, composer-autoload, composer-webuser, webusergroup
- Packaging: debian/* with minimal debhelper rules and Jenkins pipelines to build/test for multiple Debian/Ubuntu distributions.

Key commands
- Build locally (Debian packaging)
  - Update changelog entry interactively: dch -i
  - Show current version from changelog: dpkg-parsechangelog --show-field Version
  - Build binary package without signing: dpkg-buildpackage -us -uc -b
  - Alternative (debuild): debuild -us -uc -b
  - Clean: debclean or git clean -xdf (use with care)
- Build with pbuilder (as in CI) if available
  - debuild-pbuilder -i -us -uc -b
- Run the shipped tools during development
  - Update all system PHP dependencies: composer-global-update
  - Update only packages matching a keyword: composer-global-update <keyword>
  - Prepare autoloader for a specific app installed under /usr/lib/<App>:
    - As root: composer-debian <App>
  - Enable verbose Composer output for debugging:
    - export DEBCONF_DEBUG=1; composer-global-update
  - Run autoload update for a specific composer.json as a non-root user:
    - composer-autoload /path/to/composer.json
      Note: composer-autoload must not be run as root and will exit if USER=root.
  - Get configured web user (from debconf): composer-webuser

What the executables do (architecture)
- composer-debian
  - Input: an app name (directory under /usr/lib/<App>/ with composer.json)
  - Sets vendor-dir in /usr/lib/<App>/composer.json to /var/lib/composer/<App> using jq | sponge
  - Ensures ownership of /usr/lib/<App> and /var/lib/composer for the web user/group
  - Invokes composer-autoload as the web user to run composer update and generate autoload.php in the vendor directory
- composer-global-update
  - Optionally takes a keyword; scans /usr/lib/*/* for composer.json files containing the keyword
  - For each match, calls composer-debian <App>
- composer-autoload
  - Must be run as a non-root user; exports COMPOSER_HOME=/var/lib/composer and related env
  - Derives <App> and vendor-dir from the provided composer.json path and runs composer update (quiet by default or verbose if DEBCONF_DEBUG>0)
  - Verifies autoload.php exists in /var/lib/composer/<App>/autoload.php
- composer-webuser and webusergroup
  - Integrate with debconf to obtain or create the WEB_USER/WEB_GROUP used to run Composer operations
  - webusergroup creates missing system group/user if needed and exports WEB_USER/WEB_GROUP for callers

Packaging and CI
- debian/control: Build-Depends on debhelper (>=11), curl, awk, sed, po-debconf; runtime depends include composer, sudo, jq, moreutils, php-yaml
- debian/rules: Minimal debhelper invocation with an override to run debian/mkico.sh during install
- Jenkins pipelines:
  - debian/Jenkinsfile: For each distribution (e.g., debian:bullseye, bookworm, trixie; ubuntu:focal, jammy, noble), runs inside a vendor/<distribution> Docker image:
    - Calculates version from changelog (dpkg-parsechangelog) and appends BUILD_NUMBER and distro codename
    - Builds with debuild-pbuilder and collects .deb artifacts
    - Tests by creating a local apt repo from artifacts and installing them inside the container
  - debian/Jenkinsfile.release: Similar flow but uses vendor/multiflexi-<codename>:latest images and copies artifacts back to workspace

Getting started quickly
- Build a .deb locally
  1) dch -i
  2) dpkg-buildpackage -us -uc -b
  3) Find artifacts in the parent directory (../*.deb)
- Smoke-test the built package in a clean container (example with Debian bookworm)
  - docker run --rm -it -v "$PWD":/src -w /src debian:bookworm bash -lc "apt-get update && apt-get install -y sudo curl ca-certificates gnupg devscripts equivs && mk-build-deps -i -t 'apt-get -y' && dpkg -i ../*.deb || apt-get -f install -y && composer-global-update"
  Note: Adjust dependencies per your environment. This approximates the Jenkins test stage where packages are installed and tools executed.

Important details from README.md
- Installation (from VitexSoftware APT repo):
  - sudo apt install lsb-release wget apt-transport-https bzip2
  - wget -qO- https://repo.vitexsoftware.com/keyring.gpg | sudo tee /etc/apt/trusted.gpg.d/vitexsoftware.gpg
  - echo "deb [signed-by=/etc/apt/trusted.gpg.d/vitexsoftware.gpg] https://repo.vitexsoftware.com $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/vitexsoftware.list
  - sudo apt update && sudo apt install composer-debian
- Usage examples:
  - composer-global-update
  - composer-global-update nette
  - export DEBCONF_DEBUG=1; composer-global-update
- Making compatible packages (summary):
  - Libraries: use vendor "deb"; place composer.json under /usr/share/php/<LibraryDir>/; call composer-global-update deb/<libname> in postinst
  - Applications: place composer.json under /usr/lib/<AppName>/; call composer-debian <AppName> in postinst; use /var/lib/composer/<AppName>/autoloader.php

Notes
- There are no unit tests in this repository; CI validates by building .deb packages and installing them in containerized environments.
- When testing composer-autoload, ensure you run it as a non-root user; composer-debian will switch to the configured web user for you.

