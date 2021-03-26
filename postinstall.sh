#!/bin/bash

echo "Post-install..."
sudo -S apt-get update
sudo -S apt-get upgrade
sudo -S apt-get install vim python-is-python3 python3-pip curl black git
wd=`pwd`
wget https://downloads.arduino.cc/arduino-cli/arduino-cli_latest_Linux_64bit.tar.gz
tar -xvzf arduino-cli_latest_Linux_64bit.tar.gz
echo "PATH=\${PATH}:$wd" >> ~/.bashrc
wget https://downloads.arduino.cc/arduino-1.8.13-linux64.tar.xz
tar -xvJf arduino-1.8.13-linux64.tar.xz
cd arduino-1.8.13
./install.sh
sudo -S usermod -a -G dialout $USER && \
sudo -S pip3 install pyserial && \
mkdir -p hardware/espressif && \
cd hardware/espressif && \
git clone https://github.com/espressif/arduino-esp32.git esp32 && \
cd esp32 && \
git submodule update --init --recursive && \
cd tools && \
python3 get.py

