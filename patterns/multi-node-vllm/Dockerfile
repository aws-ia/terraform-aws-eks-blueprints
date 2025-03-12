# syntax=docker/dockerfile:1

FROM ubuntu:22.04

RUN <<EOT
  rm -f /etc/apt/apt.conf.d/docker-clean
  echo 'Binary::apt::APT::Keep-Downloaded-Packages "false";' > /etc/apt/apt.conf.d/keep-cache
  echo 'APT::Keep-Downloaded-Packages "false";' > /etc/apt/apt.conf.d/99custom-conf
  echo 'APT::Install-Suggests "0";' >> /etc/apt/apt.conf.d/00-docker
  echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

  # Install CUDA keyring
  apt update
  apt upgrade -y
  apt install -y \
    ca-certificates \
    curl \
    gnupg2

  curl -fsSLO https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
  dpkg -i cuda-keyring_1.1-1_all.deb
  rm cuda-keyring_1.1-1_all.deb

  apt clean
  rm -rf /var/{log,dpkg.log}
EOT

# vLLM requires python3-dev
RUN <<EOT
  apt update
  apt install -y \
    python3.11 \
    python3-dev \
    python3-pip \
    python-is-python3
  apt clean
  rm -rf /var/{log,dpkg.log}
EOT

RUN <<EOT
  pip install --no-cache-dir vllm
  pip uninstall opencv-python-headless pytest torchaudio torchvision -y

  # NCCL is installed below since its compiled/linked with aws-ofi-nccl
  rm -rf /usr/local/lib/python3.10/dist-packages/nvidia/nccl
EOT

ARG AWS_OFI_NCCL_VERSION=1.13.2-aws
ARG EFA_INSTALLER_VERSION=1.37.0
ARG NCCL_VERSION=2.25.1

# CUDA version needs to match vLLM https://github.com/vllm-project/vllm/blob/66e16a038e9fe8bf04e133858621cd9803e7145b/Dockerfile#L8
ARG CUDA_MAJOR_VERSION=12
ARG CUDA_MINOR_VERSION=4

RUN <<EOT
  apt update
  apt install -y \
    gcc-10 \
    g++-10 \
    cuda-minimal-build-${CUDA_MAJOR_VERSION}-${CUDA_MINOR_VERSION} \
    git \
    libhwloc15 \
    libhwloc-dev \
    make

  # TODO - https://github.com/vllm-project/vllm/blob/eb8b5eb183b8428f7e58adf2559e7a8d9400fc30/Dockerfile#L33-L34
  update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 110 --slave /usr/bin/g++ g++ /usr/bin/g++-10

  # EFA installer
  cd /tmp
  curl -sL https://efa-installer.amazonaws.com/aws-efa-installer-${EFA_INSTALLER_VERSION}.tar.gz | tar xvz
  cd aws-efa-installer

  # OpenMPI v4 vs v5 doesn't matter since its not used here, but v4 is slightly smaller
  ./efa_installer.sh --yes --skip-kmod --skip-limit-conf --no-verify --mpi openmpi4

  echo "/opt/amazon/openmpi/lib" >> /etc/ld.so.conf.d/000_efa.conf
  ldconfig

  # NCCL
  cd /tmp
  git clone https://github.com/NVIDIA/nccl.git -b v${NCCL_VERSION}-1
  cd nccl

  make -j $(nproc) src.build \
    BUILDDIR=/opt/nccl \
    CUDA_HOME=/usr/local/cuda \
    NVCC_GENCODE="-gencode=arch=compute_89,code=sm_89 -gencode=arch=compute_89,code=sm_89"

  echo "/opt/nccl/lib" >> /etc/ld.so.conf.d/000_efa.conf
  ldconfig

  # AWS-OFI-NCCL plugin
  cd /tmp
  curl -sL https://github.com/aws/aws-ofi-nccl/releases/download/v${AWS_OFI_NCCL_VERSION}/aws-ofi-nccl-${AWS_OFI_NCCL_VERSION}.tar.gz | tar xvz
  cd aws-ofi-nccl-${AWS_OFI_NCCL_VERSION}

  ./configure --prefix=/opt/aws-ofi-nccl/install \
    --with-mpi=/opt/amazon/openmpi \
    --with-libfabric=/opt/amazon/efa \
    --with-cuda=/usr/local/cuda \
    --enable-tests=no \
    --enable-platform-aws
  make -j $(nproc)
  make install

  echo "/opt/aws-ofi-nccl/install/lib" >> /etc/ld.so.conf.d/000_efa.conf
  ldconfig

  # Remove static libs to avoid copying them to the final image
  find / -name '*.a' | xargs rm
  rm -rf /tmp/*

  apt-get purge --autoremove -y \
    cuda-minimal-build-${CUDA_MAJOR_VERSION}-${CUDA_MINOR_VERSION} \
    git
  apt clean
  rm -rf /var/{log,dpkg.log}
EOT

WORKDIR /vllm-workspace
RUN <<EOT
  curl -O https://raw.githubusercontent.com/kubernetes-sigs/lws/main/docs/examples/vllm/build/ray_init.sh
  chmod +x ray_init.sh

  # For vLLM debug/issue reporting
  curl -O https://raw.githubusercontent.com/vllm-project/vllm/main/collect_env.py

  pip install --no-cache-dir --upgrade hf_transfer
EOT
