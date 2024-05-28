#!/bin/bash

chmod +x 1_setup_os.sh mlir.sh 2_setup_modules.sh
./1_setup_os.sh
./mlir.sh
./2_setup_modules.sh

