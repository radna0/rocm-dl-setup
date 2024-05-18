# ZLUDA-SETUP

This repository contains setup instructions for running CUDA on AMD GPUs using Zluda and PyTorch. Follow the steps below to configure your system and Docker environment.

# Project Setup Instructions

## SETUP

### Step 1: Grant Permissions
To give the necessary permissions, run:

```sh
chmod +x 1_setup_os.sh
chmod +x 2_setup_modules.sh
```

### Step 2: Run Setup Scripts
Run the following scripts to set up the OS and modules (including Zluda and PyTorch):

```sh
./1_setup_os.sh
./2_setup_modules.sh
```

## DOCKER SETUP

### Step 1: Setup Docker
Run the `docker.sh` file to set up Docker:

```sh
./docker.sh
```

### Step 2: Run Dockerfile
Navigate to the `docker` folder and run the Dockerfile:

```sh
cd docker
docker build -t your_image_name .
```

Feel free to replace `your_image_name` with a preferred name for your Docker image.