#!/bin/bash
# This script will install HybVIO from:
# https://github.com/SpectacularAI/HybVIO
# on raspberry pi

export TMPROOT=$PWD

# Create install directory
mkdir -p ~/sw/
cd ~/sw

# Install dependencies
sudo apt update
sudo apt upgrade -y
sudo apt install -y \
	vim \
	gfortran \
	clang \
	libglfw3-dev \
	libglfw3 \
	libglew-dev \
	libxkbcommon-dev \
	libc++-dev \
	libgtk2.0-dev \
	libgstreamer1.0-dev \
	libvtk6-dev \
	libavresample-dev \
	libopengl-dev \
	python3-dev \
	python3-distutils

# Install cmake 3.25.2
wget -nc https://github.com/Kitware/CMake/releases/download/v3.25.2/cmake-3.25.2.tar.gz
tar -xf cmake-3.25.2.tar.gz
cd cmake-3.25.2
./configure
make -j 4
sudo make install

cd ~/sw
rm -rf cmake*

cd $TMPROOT/3rdparty/mobile-cv-suite
if [[ $(uname -m | grep arm) ]]; then
	CPUTYPE=$(lscpu | grep Cortex | cut -d '-' -f2)
	sed -i s/HASWELL/CORTEX$CPUTYPE/g ./scripts/components/openblas.sh
fi

CC=clang CXX=clang++ ./scripts/build.sh
cd $TMPROOT
CC=clang CXX=clang++ ./src/slam/download_orb_vocab.sh
mkdir target
cd target
CC=clang CXX=clang++ cmake -DBUILD_VISUALIZATIONS=ON -DUSE_SLAM=ON ..
make -j4

# Run test
target/run-tests

# Creating alias for HybVIO
alias hybvio="$PWD/main"
