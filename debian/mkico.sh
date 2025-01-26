#!/bin/bash
PACKAGE="composer-debian"
SRC="$PACKAGE.svg"
DIR="debian/$PACKAGE/usr/share/icons/hicolor"

resolutions='16 32 48 64 128 256 512 1024'

for resolution in $resolutions
do
    mkdir -p $DIR/${resolution}x${resolution}/apps/
    inkscape -w "${resolution}" -h "${resolution}" $SRC --export-filename=$DIR/${resolution}x${resolution}/apps/$PACKAGE.png
done
mkdir -p $DIR/scalable/apps
cp $SRC $DIR/scalable/apps/$PACKAGE.svg 
echo "All done"
