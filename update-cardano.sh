#!/bin/bash

if [ -z "$1" ]
  then
    echo "Please provide a tag as an argument.  EX: (./update-cardano.sh 1.14.2)"
    exit
fi

cd ../cardano-node
git fetch --all --tags
git checkout tags/$1
cabal install cardano-node cardano-cli --installdir=/usr/local/bin