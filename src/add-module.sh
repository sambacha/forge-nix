#!/usr/bin/env bash
set -o errexit

#shellcheck disable=SC2166
[ -z "$1" -o "$(echo "$1" | tr '/' '\n' | wc -l)" != 2 ] &&
  {
    echo "Usage: $(basename "$0") <vendor>/<repo> [destdir] # 'destdir' defaults to 'vendor/repo'"
    exit 1
  }
REPO="$1"

DEST="vendor/${REPO#*/}"
[ -n "$2" ] && DEST="$2"

if $DEST $? -eq 0; then
  git submodule add --force https://github.com/"${REPO}".git "$DEST"
  git config -f .gitmodules submodule."${DEST}".ignore untracked
  git config -f .gitmodules submodule."${DEST}".branch master
  exit 0
fi

echo "ERROR: Command not found"
exit 127
# exit(127)	It indicates command not found.
