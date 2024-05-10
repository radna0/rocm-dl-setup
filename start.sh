#!/bin/bash

# Set working directory
cd /root

# Update package lists and install required packages
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
  ninja-build

# Set environment variables
export PATH="${PATH}:/opt/rocm/bin:/opt/rocm/llvm/bin:/usr/local/cuda/bin/"

# Set CUDA version
CUDA_VERSION=11-8

# Install NVIDIA CUDA packages
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb && \
  dpkg -i cuda-keyring_1.0-1_all.deb && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  nvidia-headless-no-dkms-515 \
  nvidia-utils-515 \
  cuda-cudart-${CUDA_VERSION} \
  cuda-compiler-${CUDA_VERSION} \
  libcufft-dev-${CUDA_VERSION} \
  libcusparse-dev-${CUDA_VERSION} \
  libcublas-dev-${CUDA_VERSION} \
  cuda-nvml-dev-${CUDA_VERSION} \
  libcudnn8-dev

# Set Rust version
RUST_VERSION=1.66.1

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=${RUST_VERSION}
source $HOME/.cargo/env && cargo install bindgen-cli --locked

# Set ROCM version
ROCM_VERSION=5.7.3

# Install ROCM packages
echo "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" > /etc/apt/preferences.d/rocm-pin-600
mkdir --parents --mode=0755 /etc/apt/keyrings && \
  sh -c 'wget https://repo.radeon.com/rocm/rocm.gpg.key -O - |  gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null' && \
  sh -c 'echo deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} jammy main > /etc/apt/sources.list.d/rocm.list' && \
  apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
  rocm-device-libs && \
  echo 'export PATH="$PATH:/opt/rocm/bin"' > /etc/profile.d/rocm.sh && \
  echo '/opt/rocm/lib' > /etc/ld.so.conf.d/rocm.conf && \
  ldconfig

# Set default command
bash -l
