#!/bin/bash

# Update system and install essential packages
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    nano \
    wget \
    curl \
    gnupg \
    ripgrep \
    ltrace \
    file \
    python3-minimal \
    build-essential \
    git \
    cmake \
    ninja-build \
    python3-pip

# Set environment variables
export PATH="${PATH}:/opt/rocm/bin:/opt/rocm/llvm/bin:/usr/local/cuda/bin/"
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=compute,utility

# Install CUDA
CUDA_VERSION="11-8"
sudo wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    nvidia-headless-no-dkms-515 \
    nvidia-utils-515 \
    cuda-cudart-${CUDA_VERSION} \
    cuda-compiler-${CUDA_VERSION} \
    libcufft-dev-${CUDA_VERSION} \
    libcusparse-dev-${CUDA_VERSION} \
    libcublas-dev-${CUDA_VERSION} \
    cuda-nvml-dev-${CUDA_VERSION} \
    libcudnn8-dev \
    cuda-toolkit-${CUDA_VERSION} \
    cudnn9-cuda-${CUDA_VERSION}
    
# Install Rust
RUST_VERSION="1.66.1"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo sh -s -- -y --default-toolchain=${RUST_VERSION}
source $HOME/.cargo/env
sudo apt install rustc cargo
cargo install bindgen-cli --locked

# Install ROCm
ROCM_VERSION="5.7.1"
echo "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" | sudo tee /etc/apt/preferences.d/rocm-pin-600
sudo mkdir -p /etc/apt/keyrings
sudo wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | sudo gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} jammy main" | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    rocminfo \
    rocm-smi \
    rocm-gdb \
    rocprofiler \
    rocm-smi-lib \
    hip-runtime-amd \
    comgr \
    hipblaslt-dev \
    hipfft-dev \
    rocblas-dev \
    rocsolver-dev \
    rocsparse-dev \
    miopen-hip-dev \
    rocm-device-libs
echo 'export PATH="$PATH:/opt/rocm/bin"' | sudo tee /etc/profile.d/rocm.sh
echo '/opt/rocm/lib' | sudo tee /etc/ld.so.conf.d/rocm.conf
sudo ldconfig


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


# Cleanup
cd $HOME
sudo rm -rf cuda-keyring_1.0-1_all.deb Miniconda3-latest-Linux-x86_64.sh
sudo apt-get autoclean -y
sudo apt-get autoremove -y

# Default to a login shell
sudo bash -l
