#!/usr/bin/env bash
set -e

exec 3>&1 # make stdout available as fd 3 for the result
exec 1>&2 # redirect all output to stderr for logging

source $(dirname $0)/common.sh

destination=$1

if [ -z "$destination" ]; then
  echo "usage: $0 <path/to/destination>" >&2
  exit 1
fi

# for jq
PATH=/usr/local/bin:$PATH

bin_dir="${0%/*}"
if [ "${bin_dir#/}" == "$bin_dir" ]; then
  bin_dir="$PWD/$bin_dir"
fi

payload="$(cat <&0)"

load_pubkey "$payload"
load_git_crypt_key "$payload"
configure_https_tunnel "$payload"
configure_git_ssl_verification "$payload"
configure_credentials "$payload"

uri=$(jq -r '.source.uri // ""' <<<"$payload")
branch=$(jq -r '.source.branch // ""' <<<"$payload")
git_config_payload=$(jq -r '.source.git_config // []' <<<"$payload")
ref=$(jq -r '.version.ref // "HEAD"' <<<"$payload")
override_branch=$(jq -r '.version.branch // ""' <<<"$payload")
depth=$(jq -r '(.params.depth // 0)' <<<"$payload")
fetch=$(jq -r '(.params.fetch // [])[]' <<<"$payload")
submodules=$(jq -r '(.params.submodules // "all")' <<<"$payload")
submodule_recursive=$(jq -r '(.params.submodule_recursive // true)' <<<"$payload")
submodule_remote=$(jq -r '(.params.submodule_remote // false)' <<<"$payload")
commit_verification_key_ids=$(jq -r '(.source.commit_verification_key_ids // [])[]' <<<"$payload")
commit_verification_keys=$(jq -r '(.source.commit_verification_keys // [])[]' <<<"$payload")
tag_filter=$(jq -r '.source.tag_filter // ""' <<<"$payload")
tag_regex=$(jq -r '.source.tag_regex // ""' <<<"$payload")
fetch_tags=$(jq -r '.params.fetch_tags' <<<"$payload")
gpg_keyserver=$(jq -r '.source.gpg_keyserver // "hkp://keyserver.ubuntu.com/"' <<<"$payload")
disable_git_lfs=$(jq -r '(.params.disable_git_lfs // false)' <<<"$payload")
clean_tags=$(jq -r '(.params.clean_tags // false)' <<<"$payload")
short_ref_format=$(jq -r '(.params.short_ref_format // "%s")' <<<"$payload")
timestamp_format=$(jq -r '(.params.timestamp_format // "iso8601")' <<<"$payload")
describe_ref_options=$(jq -r '(.params.describe_ref_options // "--always --dirty --broken")' <<<"$payload")
search_remote_refs_flag=$(jq -r '(.source.search_remote_refs // false)' <<<"$payload")

# If params not defined, get it from source
if [ -z "$fetch_tags" ] || [ "$fetch_tags" == "null" ]; then
  fetch_tags=$(jq -r '.source.fetch_tags' <<<"$payload")
fi

configure_git_global "${git_config_payload}"

if [ -z "$uri" ]; then
  echo "invalid payload (missing uri):" >&2
  cat $payload >&2
  exit 1
fi

branchflag=""
if [ -n "$branch" ]; then
  branchflag="--branch $branch"
fi

if [ -n "$override_branch" ]; then
  echo "Override $branch with $override_branch"
  branchflag="--branch $override_branch"
fi

depthflag=""
if test "$depth" -gt 0 2>/dev/null; then
  depthflag="--depth $depth"
fi

tagflag=""
if [ "$fetch_tags" == "false" ]; then
  tagflag="--no-tags"
elif [ -n "$tag_filter" ] || [ -n "$tag_regex" ] || [ "$fetch_tags" == "true" ]; then
  tagflag="--tags"
fi

if [ "$disable_git_lfs" == "true" ]; then
  # skip the fetching of LFS objects for all following git commands
  export GIT_LFS_SKIP_SMUDGE=1
fi

git clone --single-branch $depthflag $uri $branchflag $destination $tagflag

cd $destination

git fetch origin refs/notes/*:refs/notes/* $tagflag

if [ "$depth" -gt 0 ]; then
  "$bin_dir"/deepen_shallow_clone_until_ref_is_found_then_check_out "$depth" "$ref" "$tagflag"
else
  if [ "$search_remote_refs_flag" == "true" ] && ! [ -z "$branchflag" ] && ! git rev-list -1 $ref 2>/dev/null >/dev/null; then
    change_ref=$(git ls-remote origin | grep $ref | cut -f2)
    if ! [ -z "$change_ref" ]; then
      echo "$ref not found locally, but search_remote_refs is enabled. Attempting to fetch $change_ref first."
      git fetch origin $change_ref
    else
      echo "WARNING: couldn't find a ref for $ref listed on the remote"
    fi
  fi
  git checkout -q "$ref"
fi
