#!/bin/bash
set -e

VER=3.8.6
URL=https://ftp.jaist.ac.jp/pub/apache/maven/maven-3/$VER/binaries/apache-maven-$VER-bin.tar.gz
PKG_FILE=$(basename "$URL")
INST_DIR=/opt/mvn
SLINK_DIR=/usr/local/bin

echo "Downloading package from $URL ..."
cd /tmp
if [ ! -f "$PKG_FILE" -o "$1" = "-f" ]; then
    curl -L "$URL" -o "$PKG_FILE"
fi
echo

echo "Extracting into $INST_DIR ..."
PARENT_DIR="$(dirname "$INST_DIR")"
sudo mkdir -p $PARENT_DIR
sudo tar xaf "$PKG_FILE" -C "$PARENT_DIR"
sudo ln -sf "$PARENT_DIR/apache-maven-$VER" "$INST_DIR"
echo

echo "Creating a symbolic link in $SLINK_DIR ..."
sudo mkdir -p "$SLINK_DIR" && cd "$SLINK_DIR"
sudo ln -f -s "$INST_DIR/bin/mvn" "$SLINK_DIR"/
echo

echo "Done!"
