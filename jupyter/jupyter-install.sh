#!/bin/bash

apt-get update
apt-get install unzip openjdk-17-jdk python-is-python3 python3-pip python3-dev nodejs npm -y

# Add Jupyter user
useradd -m -d /home/jovyan -s /bin/bash jovyan
cd /home/jovyan

# Install Jupyter
pip install jupyterlab

# Get and install Java kernel for Jupyter
wget "https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip" -O ijava-kernel.zip
unzip ijava-kernel.zip -d ijava-kernel 
python3 ijava-kernel/install.py --sys-prefix
rm -rf ijava-kernel.zip

# Move notebook to user directory
mv /notebook.ipynb /home/jovyan/notebook.ipynb
mv /wine-data.json /home/jovyan/wine-data.json

# Change ownership of $HOME
chown -R jovyan /home/jovyan

exit