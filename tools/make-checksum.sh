#!/usr/bin/env bash
shell-ipfs < src/forge2nix > checksum.txt
shell-ipfs -e hex -a sha2-256 -l 256  < src/forge2nix >> checksum.txt
sleep 1

shell-ipfs $(find . -name '*.sh') > IPFS_CHECKSUM.txt
shell-ipfs -e hex -a sha2-256 -l 256 $(find . -name '*.sh') >> IPFS_CHECKSUM.txt
