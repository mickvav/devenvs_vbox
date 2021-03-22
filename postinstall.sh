#!/bin/bash

echo "Post-install..."
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim
wget https://downloads.arduino.cc/arduino-1.8.13-linux64.tar.xz
tar -xvJf arduino-1.8.13-linux64.tar.xz
cd arduino-1.8.13
./install.sh
