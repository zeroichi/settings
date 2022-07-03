#!/bin/bash
set -e

VER=3.8.6
URL=https://ftp.jaist.ac.jp/pub/apache/maven/maven-3/$VER/binaries/apache-maven-$VER-bin.tar.gz
# note: paste hash from https://downloads.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz.sha512
HASH=f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26
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
