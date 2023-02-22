TZ=Europe/Zurich
# TODO: ccache
# xz-utils -> = deps for tar
# && sed -i 's@archive.ubuntu.com@ubuntu.ethz.ch@' /etc/apt/sources.list \
sudo mkdir -p cuda
ls -la ; pwd    
sudo apt update --quiet
sudo apt upgrade -y --quiet 
DEBIAN_FRONTEND=noninteractive sudo \
   apt install -y --no-install-recommends \
   wget xz-utils unzip \
   cmake ninja-build \
   g++ libopenmpi-dev \
   nvidia-cuda-dev libcub-dev libthrust-dev libcublas11
sudo apt clean autoremove


sudo mkdir -p /usr/local/games/cuda
sudo chmod 777 /usr/local/games/cuda
# wget --no-check-certificate
wget --no-check-certificate \
   https://developer.download.nvidia.com/compute/cuda/redist/cuda_nvcc/linux-x86_64/cuda_nvcc-linux-x86_64-11.8.89-archive.tar.xz \
   https://developer.download.nvidia.com/compute/cuda/redist/cuda_cudart/linux-x86_64/cuda_cudart-linux-x86_64-11.8.89-archive.tar.xz
tar --strip-components 1 -C /usr/local/games/cuda -xf /usr/local/games/cuda_nvcc-linux-x86_64-11.8.89-archive.tar.xz
tar --strip-components 1 -C /usr/local/games/cuda -xf /usr/local/games/cuda_cudart-linux-x86_64-11.8.89-archive.tar.xz
ln -s /usr/local/games/cuda/lib/ /usr/local/games/cuda/lib64


cd /usr/local/games/ 
PATH="$PATH:/usr/local/games/cuda/bin" \
CPATH="$CPATH:/usr/include:/usr/lib/x86_64-linux-gnu/openmpi/include" \
   cmake -GNinja -S SPH-EXA.git -B build \
   -DGPU_DIRECT=OFF \
   -DBUILD_ANALYTICAL=OFF \
   -DBUILD_TESTING=OFF \
   -DSPH_EXA_WITH_H5PART=OFF \
   -DSPH_EXA_WITH_FFTW=OFF \
   -DCMAKE_BUILD_TYPE=Debug \
   -DCMAKE_CXX_COMPILER=mpicxx \
   -DCMAKE_C_COMPILER=mpicc \
   -DCMAKE_CUDA_COMPILER=nvcc \
   -DCMAKE_CUDA_ARCHITECTURES=80

cmake --build build -t sphexa-cuda `grep processor /proc/cpuinfo | wc -l`
ls -l ./build/main/src/sphexa/sphexa-cuda

# -> ./build/main/src/sphexa/sphexa-cuda
# TODO: cublas_v2.h
# TODO: ccache
# && wget --quiet --no-check-certificate https://github.com/unibas-dmi-hpc/SPH-EXA/archive/refs/heads/develop.zip \
# && unzip -q develop.zip \
# && nvcc --version \
# && mpicxx --version \
# && ln -s SPH-EXA-develop SPH-EXA.git \

