#!/bin/bash
# This script will install HybVIO from:
# https://github.com/SpectacularAI/HybVIO
# on raspberry pi

export TMPROOT=$PWD
export USRNAME=$(pwd | cut -d '/' -f 3)


# Download all submodules
git submodule update --init --recursive

# Create tmp directory
mkdir -p ~/tmp
cd ~/tmp

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
	python3-distutils \
  python3-matplotlib
  
# Install cmake 3.25.2
wget -nc https://github.com/Kitware/CMake/releases/download/v3.25.2/cmake-3.25.2.tar.gz
tar -xf cmake-3.25.2.tar.gz
cd cmake-3.25.2
./configure
make -j 4
sudo make install

rm -rf ~/tmp

cd $TMPROOT/3rdparty/mobile-cv-suite
if [[ $(uname -m | grep arm) ]]; then
	CPUTYPE=$(lscpu | grep Cortex | cut -d '-' -f2)
	sed -i s/HASWELL/CORTEX$CPUTYPE/g ./scripts/components/openblas.sh
fi


CC=clang CXX=clang++ ./scripts/build.sh
cd $TMPROOT
CC=clang CXX=clang++ ./src/slam/download_orb_vocab.sh
mkdir -p target
cd target
CC=clang CXX=clang++ cmake -DBUILD_VISUALIZATIONS=ON -DUSE_SLAM=ON -DOpenGL_GL_PREFERENCE=GLVN ..
make -j4

cd $TMPROOT
sudo chown -R $USRNAME:$USRNAME .

# Run test
./target/run-tests

# Creating alias for HybVIO
echo "alias hybvio="$PWD/target/main"" >> /home/$USRNAME/.bashrc
