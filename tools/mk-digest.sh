#!/usr/bin/env bash
set -eEu -o pipefail
shopt -s extdebug
IFS=$'\n\t'
trap 'onFailure $?' ERR

function onFailure() {
  echo "Unhandled script error $1 at ${BASH_SOURCE[0]}:${BASH_LINENO[0]}" >&2
  exit 1
}
shell-ipfs --version
shell-ipfs < src/forge2nix > checksum.txt
shell-ipfs -e hex -a sha2-256 -l 256  < src/forge2nix >> checksum.txt