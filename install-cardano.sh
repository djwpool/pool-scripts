#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide a tag as an argument.  EX: (./install-cardano.sh 1.14.2)"
    exit
fi


sudo apt-get update -y
sudo apt-get install build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf -y

cd ..
wget https://downloads.haskell.org/~cabal/cabal-install-3.2.0.0/cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
tar -xf cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz
rm cabal-install-3.2.0.0-x86_64-unknown-linux.tar.xz cabal.sig
mkdir -p ~/.local/bin
mv cabal ~/.local/bin/

echo "export PATH=\"$HOME/.local/bin:$HOME/.cabal/bin:$PATH\"" >> .profile
echo "export LD_LIBRARY_PATH=\"/usr/local/lib:$LD_LIBRARY_PATH\"" >> .profile

source $HOME/.profile

cabal update

wget https://downloads.haskell.org/~ghc/8.6.5/ghc-8.6.5-x86_64-deb9-linux.tar.xz
tar -xf ghc-8.6.5-x86_64-deb9-linux.tar.xz
rm ghc-8.6.5-x86_64-deb9-linux.tar.xz
cd ghc-8.6.5
./configure
make install
cd ..

git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
make install

cd ..

sed -i 's/-- overwrite-policy:/overwrite-policy: always/g' /root/.cabal/config
sed -i 's/-- install-method:/install-method: copy/g' /root/.cabal/config

git clone https://github.com/input-output-hk/cardano-node.git
cd cardano-node
git fetch --all --tags
git checkout tags/$1

cabal install cardano-node cardano-cli --installdir=/usr/local/bin