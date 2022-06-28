#!/usr/bin/env bash

add_git_metadata_url() {
  local commit=$(git rev-parse HEAD)
  local origin=$(git remote get-url --all origin) 2> /dev/null

  # This is not exhaustive for remote URL formats, but does cover the
  # most common hosting scenarios for where a commit URL exists
  if [[ ! $origin =~ ^(https?://|ssh://git@|git@)([^/]+)/(.*)$ ]]; then
    jq ". + []"
  else
    local host=${BASH_REMATCH[2]}
    local repo_path=${BASH_REMATCH[3]%.git}

    # Remap scp-style names so that "github.com:concourse" + "git-resource"
    # becomes "github.com" + "concourse/git-resource"
    if [[ ${BASH_REMATCH[1]} == "git@" && $host == *:* ]]; then
      repo_path="${host#*:}/${repo_path}"
      host=${host%%:*}
    fi

    local url=""
    case $host in
      *github* | *gitlab* | *gogs* )
        url="https://${host}/${repo_path}/commit/${commit}" ;;
      *bitbucket* )
        url="https://${host}/${repo_path}/commits/${commit}";;
    esac

    if [ -n "$url" ]; then
      jq ". + [
        {name: \"url\", value: \"${url}\"}
      ]"
    else
      jq ". + []"
    fi
  fi
}
