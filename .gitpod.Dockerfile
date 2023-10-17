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

# Update system and install singularity
RUN sudo apt-get update && sudo apt-get install -y build-essential \
    libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup-bin && \
    GO_VERSION=$(go version | awk '{print $3}' | tr -d 'go') && \
    if [ "$(printf '%s\n' "1.16" "$GO_VERSION" | sort -V | head -n1)" != "1.16" ]; then \
        VERSION=$(curl -s https://go.dev/VERSION?m=text | tr -d '\n') && \
        wget https://dl.google.com/go/$VERSION.linux-amd64.tar.gz && \
        sudo tar -C /usr/local -xzf $VERSION.linux-amd64.tar.gz && \
        rm $VERSION.linux-amd64.tar.gz; \
    fi && \
    VERSION=3.9.0 && \
    wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz && \
    tar -xzf singularity-ce-${VERSION}.tar.gz && rm singularity-ce-${VERSION}.tar.gz && \
    cd singularity-ce-${VERSION} && \
    ./mconfig --without-suid && \
    make -C builddir && \
    sed -i 's;mount proc = yes;mount proc = no;g' builddir/singularity.conf && \
    sed -i '/bind path = \/etc\/hosts/a bind path = \/proc' builddir/singularity.conf && \
    sudo make -C builddir install

# Install micromamba
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba && \
    mkdir -p ~/micromamba && \
    ./bin/micromamba shell init -s bash -p ~/micromamba && \
    echo "source ~/micromamba/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    rm -rf ./bin/micromamba