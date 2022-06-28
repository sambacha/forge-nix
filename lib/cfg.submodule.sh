#!/usr/bin/env bash

configure_submodule_credentials() {
  local username
  local password
  if [[ "$(jq -r '.source.submodule_credentials // ""' <<<"$1")" == "" ]]; then
    return
  fi

  for k in $(jq -r '.source.submodule_credentials | keys | .[]' <<<"$1"); do
    host=$(jq -r --argjson k "$k" '.source.submodule_credentials[$k].host // ""' <<<"$1")
    username=$(jq -r --argjson k "$k" '.source.submodule_credentials[$k].username // ""' <<<"$1")
    password=$(jq -r --argjson k "$k" '.source.submodule_credentials[$k].password // ""' <<<"$1")
    if [ "$username" != "" -a "$password" != "" -a "$host" != "" ]; then
      echo "machine $host login $username password $password" >>"${HOME}/.netrc"
    fi
  done
}

configure_credentials() {
  local username=$(jq -r '.source.username // ""' <<<"$1")
  local password=$(jq -r '.source.password // ""' <<<"$1")

  rm -f $HOME/.netrc
  configure_submodule_credentials "$1"

  if [ "$username" != "" -a "$password" != "" ]; then
    echo "default login $username password $password" >>"${HOME}/.netrc"
  fi
}
