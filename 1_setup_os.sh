#!/bin/bash

# Update system and install essential packages
sudo apt-get update -y && sudo apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    nano \
    wget \
    curl \
    gnupg \
    ripgrep \
    ltrace \
    file \
    build-essential \
    git \
    cmake \
    ninja-build \



# Install ROCm

sudo apt update
wget http://repo.radeon.com/amdgpu-install/23.40.2/ubuntu/jammy/amdgpu-install_6.0.60002-1_all.deb
sudo apt install -y ./amdgpu-install_6.0.60002-1_all.deb
sudo amdgpu-install -y --usecase=graphics,rocm,hip,hiplibsdk
sudo usermod -a -G render,video $LOGNAME



# Install Miniconda
cd $HOME
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
chmod +x Miniconda3-latest-Linux-x86_64.sh
./Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
echo 'export PATH="$HOME/miniconda3:$PATH"' >> $HOME/.bashrc
source $HOME/miniconda3/etc/profile.d/conda.sh
source $HOME/.bashrc
conda init
conda --version
source $HOME/.bashrc



# Cleanup
cd $HOME
sudo rm -rf Miniconda3-latest-Linux-x86_64.sh amdgpu-install_6.0.60002-1_all.deb
sudo apt-get autoclean -y
sudo apt-get autoremove -y

# Default to a login shell
source $HOME/.bashrc
