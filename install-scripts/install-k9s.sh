#!/bin/bash
set -e

VER=v0.32.7
URL=https://github.com/derailed/k9s/releases/download/$VER/k9s_Linux_amd64.tar.gz
PKG_FILE=$(basename "$URL")
INST_DIR=/opt/k9s
SLINK_DIR=/usr/local/bin
 
echo "Downloading package from $URL ..."
cd /tmp
if [ ! -f "$PKG_FILE" -o "$1" = "-f" ]; then
    curl -L "$URL" -o "$PKG_FILE"
else
    echo "/tmp/$PKG_FILE already exists. skip downloading"
    echo "(if you want to force downloading, pass -f option)"
fi
echo

echo "Extracting into $INST_DIR ..."
sudo mkdir -p "$INST_DIR"
sudo tar xaf "$PKG_FILE" -C "$INST_DIR"
echo

echo "Creating a symbolic link in $SLINK_DIR ..."
sudo mkdir -p "$SLINK_DIR" && cd "$SLINK_DIR"
sudo ln -f -s "$INST_DIR"/k9s "$SLINK_DIR"/
echo

echo "Done!"
