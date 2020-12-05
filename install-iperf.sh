#!/bin/bash
# vim: set ts=2 sw=2 et:

# create a directory to clone source in
mkdir -p ~/repos && cd ~/repos

# clone source code
git clone https://github.com/esnet/iperf.git

# compile & install
cd iperf
./configure --enable-static-bin && make && sudo make install
