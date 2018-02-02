# ----------------------------------------------------------------------------
#
# Package       : MXNet
# Version       : 1.0.0
# Source repo   : https://github.com/apache/incubator-mxnet.git
# Tested on     : ubuntu_16.04
# Script License: Apache License, Version 2 or later
# Maintainer    : Sandip Giri <sgiri@us.ibm.com>
#
# Disclaimer: This script has been tested in non-root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------
#!/bin/bash
set -x

# Building MXNet from source is a 2 step process.
   # 1.Build the MXNet core shared library, libmxnet.so, from the C++ sources.
   # 2.Build the language specific bindings. Example - Python bindings, Scala bindings.

# ---------------------- Build the MXNet core shared library ----------------------
# Install build tools and git
sudo apt-get update
sudo apt-get install -y build-essential git

# Install OpenBLAS
# MXNet uses BLAS and LAPACK libraries for accelerated numerical computations on CPU machine.
# There are several flavors of BLAS/LAPACK libraries - OpenBLAS, ATLAS and MKL. In this step we install OpenBLAS.
# You can choose to install ATLAS or MKL.
sudo apt-get install -y libopenblas-dev liblapack-dev

# Install OpenCV.
# MXNet uses OpenCV for efficient image loading and augmentation operations.
sudo apt-get install -y libopencv-dev

# Download MXNet sources and build MXNet core shared library
git clone --recursive https://github.com/apache/incubator-mxnet.git mxnet
cd mxnet
git checkout 1.0.0
make -j $(nproc) USE_OPENCV=1 USE_BLAS=openblas USE_PROFILER=1
rm -r build
# Note - USE_OPENCV and USE_BLAS are make file flags to set compilation options to use OpenCV and BLAS library.
# You can explore and use more compilation options in make/config.mk.


# ----------------------------- Build the MXNet Python binding --------------------------
# Install prerequisites - python, setup-tools, python-pip and numpy.
sudo apt-get install -y python-dev python-setuptools python-numpy python-pip

# Install the MXNet Python binding.
cd python
sudo pip install --upgrade pip
sudo pip install -e .

# Install Graphviz. (Optional, needed for graph visualization using mxnet.viz package).
sudo apt-get install graphviz -y
sudo pip install graphviz

# Running the unit tests (run the following from MXNet root directory)
cd ..
sudo pip install pytest nose numpy==1.12.0
sudo apt-get install -y python-scipy
python -m pytest -v tests/python/unittest
python -m pytest -v tests/python/train

# Note : If the tests are failing with " Segmentation fault  (core dumped)" error, 
# then we need to rerun the test command 2 or 3 times to pass the tests.
