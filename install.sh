#!/bin/bash



# Function to update and install packages if needed
update_and_install() {
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y --install-suggests ca-certificates nano wget curl python3-minimal build-essential git cmake ninja-build
}

set_environment_variables() {
    export PATH="${PATH}:/opt/rocm/bin:/opt/rocm/llvm/bin:/usr/local/cuda/bin/"
}


# Function to install Rust
install_rust() {
    if ! command -v rustup &> /dev/null; then
        RUST_VERSION=1.66.1
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain=${RUST_VERSION}
        source $HOME/.cargo/env && cargo install bindgen-cli --locked
        sudo apt install -y rustc
    else
        echo "Rust is already installed."
    fi
}

# Function to install ROCM packages
install_rocm_packages() {
    if [ -d "/opt/rocm" ]; then
        echo "ROCM packages are already installed."
    else
        ROCM_VERSION=5.7.1
        echo "Package: *\nPin: release o=repo.radeon.com\nPin-Priority: 600" | sudo tee /etc/apt/preferences.d/rocm-pin-600
        sudo mkdir -p /etc/apt/keyrings
        sudo apt install -y "linux-headers-$(uname -r)" "linux-modules-extra-$(uname -r)"
        sudo apt update -y && sudo apt upgrade -y
        wget https://repo.radeon.com/amdgpu-install/${ROCM_VERSION}/ubuntu/jammy/amdgpu-install_5.7.50701-1_all.deb
        sudo apt install -y ./amdgpu-install_5.7.50701-1_all.deb
        sudo apt update -y && sudo apt upgrade -y
        sudo amdgpu-install --usecase=workstation,rocm,opencl
        echo 'export PATH="$PATH:/opt/rocm/bin"' | sudo tee /etc/profile.d/rocm.sh
        echo '/opt/rocm/lib' | sudo tee /etc/ld.so.conf.d/rocm.conf
        sudo ldconfig
    fi
}

# Function to install CUDA Toolkit
install_cuda() {
    if [ ! -d "/usr/local/cuda" ]; then
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
        wget https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run
        sudo sh cuda_11.8.0_520.61.05_linux.run --silent --toolkit --toolkitpath=/usr/local/cuda
    else
        echo "CUDA is already installed."
    fi
}

# Function to install Anaconda
install_anaconda() {
    if [ ! -d "$HOME/anaconda3" ]; then
        curl -O https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
        chmod +x Anaconda3-2023.09-0-Linux-x86_64.sh
        bash Anaconda3-2023.09-0-Linux-x86_64.sh -b -p $HOME/anaconda3
        export PATH="$HOME/anaconda3/bin:$PATH"
        source $HOME/anaconda3/etc/profile.d/conda.sh
        source ~/.bashrc
        conda init bash
        conda info
        conda update conda
    else
        echo "Anaconda is already installed."
    fi
}

# Function to install Zluda
install_zluda() {
    if [ ! -d "$HOME/ZLUDA/target/release" ]; then
        git clone https://github.com/vosen/ZLUDA.git $HOME/ZLUDA
        cd $HOME/ZLUDA
        cargo xtask --release
    else
        echo "Zluda is already installed."
    fi
}

# Function to install PyTorch
install_pytorch() {
    if [ ! -d "$HOME/pytorch" ]; then
        git clone https://github.com/pytorch/pytorch $HOME/pytorch
        cd $HOME/pytorch
        git submodule sync
        git submodule update --init --recursive
        export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
        export TORCH_CUDA_ARCH_LIST="6.1+PTX"
        export CUDAARCHS=61
        export CMAKE_CUDA_ARCHITECTURES=61
        export USE_SYSTEM_NCCL=1
        export USE_NCCL=0
        export USE_EXPERIMENTAL_CUDNN_V8_API=OFF
        export DISABLE_ADDMM_CUDA_LT=1
        export USE_ROCM=0
        LD_LIBRARY_PATH="$HOME/ZLUDA/target/release:$LD_LIBRARY_PATH" python setup.py develop
    else
        echo "PyTorch is already installed."
    fi
}

cd $HOME

# Run functions
update_and_install
set_environment_variables
install_rocm_packages
install_rust
install_cuda
install_anaconda
install_zluda
install_pytorch

cd $HOME

# Set default command
bash -l
