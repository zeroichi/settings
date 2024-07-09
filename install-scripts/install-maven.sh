#!/bin/bash
set -e

VER=3.9.8
URL=https://dlcdn.apache.org/maven/maven-3/$VER/binaries/apache-maven-${VER}-bin.tar.gz
# note: paste hash from https://downloads.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz.sha512
HASH=7d171def9b85846bf757a2cec94b7529371068a0670df14682447224e57983528e97a6d1b850327e4ca02b139abaab7fcb93c4315119e6f0ffb3f0cbc0d0b9a2
PKG_FILE=$(basename "$URL")
INST_DIR=/opt/mvn
SLINK_DIR=/usr/local/bin

echo "Downloading package from $URL ..."
cd /tmp
if [ ! -f "$PKG_FILE" -o "$1" = "-f" ]; then
    curl -L "$URL" -o "$PKG_FILE"
    CALC_HASH=$(sha512sum "$PKG_FILE" | awk '{print $1}')
    if [ $HASH != "$CALC_HASH" ]; then
        echo "ERROR: sha512 hashes does not match"
        echo "  expected:   $HASH"
        echo "  downloaded: $CALC_HASH"
        exit 1
    fi
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
