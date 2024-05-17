#!/bin/bash



# Install Zluda
git clone --recurse-submodules https://github.com/vosen/ZLUDA.git $HOME/ZLUDA
cd $HOME/ZLUDA
cargo xtask --release


# Install PyTorch
git clone --recursive https://github.com/pytorch/pytorch $HOME/pytorch
cd $HOME/pytorch
git submodule sync
git submodule update --init --recursive
conda install -y cmake ninja
pip install -r requirements.txt
export CMAKE_PREFIX_PATH=${CONDA_PREFIX:-"$(dirname $(which conda))/../"}
export TORCH_CUDA_ARCH_LIST="6.1+PTX"
export CUDAARCHS=61
export CMAKE_CUDA_ARCHITECTURES=61
export USE_SYSTEM_NCCL=1
export USE_NCCL=0
export USE_EXPERIMENTAL_CUDNN_V8_API=OFF
export DISABLE_ADDMM_CUDA_LT=1
LD_LIBRARY_PATH="$HOME/ZLUDA/target/release:$LD_LIBRARY_PATH" python3 setup.py develop

# Cleanup
cd $HOME


# Default to a login shell
sudo bash -l