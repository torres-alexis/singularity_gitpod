#!/bin/bash

# Update system and install required dependencies
sudo apt-get update && sudo apt-get install -y build-essential \
    libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup-bin

# Check the installed Go version
GO_VERSION=$(go version | awk '{print $3}' | tr -d 'go')

# Compare Go version with the required minimum version (1.16)
if [ "$(printf '%s\n' "1.16" "$GO_VERSION" | sort -V | head -n1)" = "1.16" ]; then
    echo "Go version is up to date: $GO_VERSION"
else
    echo "Updating Go to the latest version"
    VERSION=$(curl -s https://go.dev/VERSION?m=text | tr -d '\n')
    wget https://dl.google.com/go/$VERSION.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf $VERSION.linux-amd64.tar.gz
    rm $VERSION.linux-amd64.tar.gz
    export GOROOT=/usr/local/go
    export PATH=$GOROOT/bin:$PATH
    echo "Go updated to version: $(go version | awk '{print $3}')"
fi

# Set the Singularity version you want to install
VERSION=3.9.0

# Download the specified SingularityCE release
wget https://github.com/sylabs/singularity/releases/download/v${VERSION}/singularity-ce-${VERSION}.tar.gz

# Extract the downloaded archive
tar -xzf singularity-ce-${VERSION}.tar.gz && rm singularity-ce-${VERSION}.tar.gz

# Change into the extracted directory
cd singularity-ce-${VERSION}

# Compile and install SingularityCE
## Custom setting: mount proc is set to no
./mconfig --without-suid && \
make -C builddir && \
sed -i 's;mount proc = yes;mount proc = no;g' builddir/singularity.conf && \
sed -i '/bind path = \/etc\/hosts/a bind path = \/proc' builddir/singularity.conf && \
sudo make -C builddir install

# Verify the installation
singularity --version