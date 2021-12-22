#!/bin/bash
set -e

VER=${VER:-1.6}
URL="https://github.com/stedolan/jq/releases/download/jq-${VER}/jq-linux64"
PKG_FILE=$(basename "$URL")
INST_DIR=/usr/local/bin

echo "Downloading package from $URL ..."
cd /tmp
if [ ! -f "$PKG_FILE" -o "$1" = "-f" ]; then
    curl -L "$URL" -o "$PKG_FILE"
fi
echo

echo "Installing into $INST_DIR ..."
sudo install -m 755 "$PKG_FILE" $INST_DIR/jq
echo

$INST_DIR/jq --version

echo "Done!"
