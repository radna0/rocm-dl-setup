#!/bin/bash

cd $HOME

#Installing Pytorch
pip install torch==2.2.2 torchvision==0.17.2 torchaudio==2.2.2 --index-url https://download.pytorch.org/whl/rocm5.7



#Installing Flash Attention
git clone https://github.com/ROCmSoftwarePlatform/triton.git
cd triton
git checkout triton-mlir

cd python
pip3 install ninja cmake; # build time dependencies
pip3 install -e .


# Cleanup
cd $HOME
