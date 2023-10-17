FROM gitpod/workspace-full

# Set up the non-interactive frontend
ENV DEBIAN_FRONTEND=noninteractive

# Install custom tools, runtime, etc.
# install-packages is a wrapper for `apt` that helps skip a few commands in the docker env.
RUN sudo install-packages \
          binwalk \
          clang \
          tmux

# Apply user-specific settings

# Install Singularity
RUN sudo apt-get update && \
    sudo apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup && \
    wget https://golang.org/dl/go1.17.2.linux-amd64.tar.gz && \
    sudo tar -C /usr/local -xzvf go1.17.2.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc && \
    source ~/.bashrc && \
    export VERSION=3.9.1 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity && \
    ./mconfig && \
    make -C builddir && \
    sudo make -C builddir install

# Install and setup micromamba
RUN wget https://micro.mamba.pm/api/micromamba/linux-64/latest -O micromamba.tar.bz2 && \
    mkdir -p ~/micromamba && \
    tar -xvjf micromamba.tar.bz2 -C ~/micromamba --strip-components 1 && \
    rm micromamba.tar.bz2 && \
    echo 'export MAMBA_ROOT_PREFIX=~/micromamba' >> ~/.bashrc && \
    echo 'export MAMBA_EXE=~/micromamba/bin/micromamba' >> ~/.bashrc && \
    echo 'source ~/micromamba/etc/profile.d/mamba.sh' >> ~/.bashrc