#!/bin/bash

echo "Post-install..."
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install vim
#wget https://downloads.arduino.cc/arduino-1.8.13-linux64.tar.xz
#tar -xvJf arduino-1.8.13-linux64.tar.xz
cd arduino-1.8.13
./install.sh
sudo usermod -a -G dialout $USER && \
sudo apt-get install git python3-pip && \
sudo pip3 install pyserial && \
mkdir -p hardware/espressif && \
cd hardware/espressif && \
git clone https://github.com/espressif/arduino-esp32.git esp32 && \
cd esp32 && \
git submodule update --init --recursive && \
cd tools && \
python3 get.py

