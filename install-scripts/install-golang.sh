#!/bin/bash
set -e

VER=1.16
URL=https://golang.org/dl/go${VER}.linux-amd64.tar.gz
PKG_FILE=$(basename "$URL")
INST_DIR=/usr/local
 
echo "Downloading package from $URL ..."
cd /tmp
if [ ! -f "$PKG_FILE" -o "$1" = "-f" ]; then
    curl -L "$URL" -o "$PKG_FILE"
else
    echo "$PWD/$PKG_FILE already exists. Download skipped"
fi
echo

echo "Extracting into $INST_DIR ..."
sudo mkdir -p "$INST_DIR"
sudo tar xaf "$PKG_FILE" -C "$INST_DIR"
echo

echo "Adding to PATH ..."
PROFILE_FILE=~/.profile
[ -r ~/.bash_login ] && PROFILE_FILE=~/.bash_login
[ -r ~/.bash_profile ] && PROFILE_FILE=~/.bash_profile
echo 'export PATH=$PATH:'"${INST_DIR}/go/bin" >> $PROFILE_FILE
echo "export GOROOT=${INST_DIR}/go" >> $PROFILE_FILE

echo "Done!"
