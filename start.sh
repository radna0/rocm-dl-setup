#!/bin/bash
cd ~

# Update package lists and install required packages
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y --no-install-recommends \
  ca-certificates \
  nano \
  wget \
  curl \
  python3-minimal \
  build-essential \
  git \
  cmake \
  ninja-build

sudo apt update -y && sudo apt upgrade -y

# Set environment variables
export PATH="${PATH}:/opt/rocm/bin:/opt/rocm/llvm/bin:/usr/local/cuda/bin/"

# Set CUDA version
CUDA_VERSION=11-8

# Install NVIDIA CUDA packages
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb
sudo dpkg -i cuda-keyring_1.0-1_all.deb
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y --no-install-recommends \
  nvidia-headless-no-dkms-515 \
  nvidia-utils-515 \
  cuda-cudart-${CUDA_VERSION} \
  cuda-compiler-${CUDA_VERSION} \
  libcufft-dev-${CUDA_VERSION} \
  libcusparse-dev-${CUDA_VERSION} \
  libcublas-dev-${CUDA_VERSION} \
  cuda-nvml-dev-${CUDA_VERSION} \
  libcudnn8-dev
  
sudo apt update -y && sudo apt upgrade -y

# Set Rust version
RUST_VERSION=1.66.1

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=${RUST_VERSION}
source $HOME/.cargo/env && cargo install bindgen-cli --locked

sudo apt update -y && sudo apt upgrade -y

# Set ROCM version
ROCM_VERSION=5.7.3

# Install ROCM packages
echo "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" | sudo tee /etc/apt/preferences.d/rocm-pin-600
sudo mkdir -p /etc/apt/keyrings
wget -O - https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} jammy main" | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y --no-install-recommends \
  rocminfo \
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


sudo apt update -y && sudo apt upgrade -y

# Install Anaconda
curl -O https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
bash Anaconda3-2023.09-0-Linux-x86_64.sh -b -p $HOME/anaconda3
export PATH="$HOME/anaconda3/bin:$PATH"
source $HOME/anaconda3/etc/profile.d/conda.sh
conda init bash
conda info
conda update conda

sudo apt update -y && sudo apt upgrade -y

# Install CUDA Toolkit
wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
sudo sh cuda_11.8.0_520.61.05_linux.run --silent --toolkit --toolkitpath=/usr/local/cuda

sudo apt update -y && sudo apt upgrade -y

# Clone Zluda
git clone https://github.com/vosen/ZLUDA.git
cd ZLUDA

# Build Zluda
cargo xtask --release

ZLUDA_DIRECTORY="/ZLUDA/target/release"

# Clone PyTorch
cd ~
git clone https://github.com/pytorch/pytorch
cd pytorch
git submodule sync
git submodule update --init --recursive

# Set CMAKE_PREFIX_PATH
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}

# Set environment variables for PyTorch build
export TORCH_CUDA_ARCH_LIST="6.1+PTX"
export CUDAARCHS=61
export CMAKE_CUDA_ARCHITECTURES=61
export USE_SYSTEM_NCCL=1
export USE_NCCL=0
export USE_EXPERIMENTAL_CUDNN_V8_API=OFF
export DISABLE_ADDMM_CUDA_LT=1
export USE_ROCM=0

# Build PyTorch
LD_LIBRARY_PATH="${ZLUDA_DIRECTORY}:$LD_LIBRARY_PATH" python setup.py develop

# Set default command
bash -l
