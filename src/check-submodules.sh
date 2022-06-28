#!/usr/bin/env bash
set -e

if [[ -f .gitmodules ]]; then
# shellcheck disable=SC2034
  git config --file .gitmodules --get-regexp 'path|url' | while read -r TMP S_PATH && read -r TMP S_URL; do
    S_HASH=$(git submodule status --cached "${S_PATH}" | sed 's/^\s*\(\S\+\).*$/\1/')
    echo "${S_URL} ${S_HASH}"
    done
fi
