#!/bin/bash
set -e

IDEA_URL=https://download.jetbrains.com/idea/ideaIC-2020.2.3.tar.gz
IDEA_FILE=$(basename "$IDEA_URL")
IDEA_INST_DIR=/opt
SLINK_DIR=/usr/local/bin
 
echo "Downloading IntelliJ IDEA tar-ball ..."
cd /tmp
if [ ! -f "$IDEA_FILE" ]; then
    curl -L "$IDEA_URL" -o "$IDEA_FILE"
fi
echo

echo "Extracting into $IDEA_INST_DIR ..."
sudo tar xaf "$IDEA_FILE" -C "$IDEA_INST_DIR"
echo

echo "Creating a symbolic link in $SLINK_DIR ..."
cd "$IDEA_INST_DIR"
sudo ln -f -s $(\ls -rtd idea-* | tail -n1) idea
sudo mkdir -p "$SLINK_DIR" && cd "$SLINK_DIR"
sudo ln -f -s "$IDEA_INST_DIR"/idea/bin/idea.sh "$SLINK_DIR"/idea.sh
echo

echo "Done!"
