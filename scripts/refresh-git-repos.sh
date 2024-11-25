#!/bin/bash
set -euo pipefail

# Usage instructions
usage() {
  echo "Usage: $0 [start_directory]"
  echo "Recursively refresh git repositories starting from the current directory."
  echo "If 'start_directory' is specified, skips repositories until that directory is reached."
}

# Parse the starting directory from the first argument, if provided
start_from="${1:-}"
found_start=false

# Check for help flag or incorrect number of arguments
if [[ "${1:-}" == "--help" || "$#" -gt 1 ]]; then
  usage
  exit 1
fi

# Check if the start directory exists
if [ -n "$start_from" ] && [ ! -d "$start_from" ]; then
  echo "Error: start_directory '$start_from' does not exist."
  usage
  exit 1
fi

# Function to refresh a git repository
refresh_git_repo() {
  local repo_dir="$1"
  cd "$repo_dir" || return
  if git show-ref --quiet refs/heads/master; then
    git switch master
  elif git show-ref --quiet refs/heads/main; then
    git switch main
  else
    echo "No 'master' or 'main' branch found in $(pwd). Skipping pull."
    cd - > /dev/null
    return
  fi
  git pull --rebase
  cd - > /dev/null
}

# Recursive function to find and refresh git repositories
find_and_refresh_git_repos_recursively() {
  for dir in "$1"/*; do
    if [ -d "$dir" ]; then
      if [ -d "$dir/.git" ]; then
        local real_dir
        real_dir="$(realpath "$dir")"
        if [ "$found_start" = false ]; then
          if [ -z "$start_from" ] || [ "$real_dir" == "$start_from" ]; then
            found_start=true
          else
            echo "Skipping git repository '$real_dir' (before start point)"
            continue
          fi
        fi
        echo "Refreshing git repository in '$real_dir'"
        refresh_git_repo "$dir"
      else
        find_and_refresh_git_repos_recursively "$dir"
      fi
    else
      echo "Skipping '$dir' (not a directory)"
    fi
  done
}

# Start the recursive search from the current directory
find_and_refresh_git_repos_recursively "$(pwd)"


##!/bin/bash
#set -euo pipefail
#
#start_from="${1:-}"
#found_start=false
#
#refresh_git_repo() {
#  if git show-ref --quiet refs/heads/master; then
#    git switch master
#  elif git show-ref --quiet refs/heads/main; then
#    git switch main
#  else
#    echo "No master or main branch found in $(pwd)"
#    return
#  fi
#  git pull --rebase
#}
#
#find_and_refresh_git_repos_recursively() {
#  for dir in "$1"/*; do
#    if [ -d "$dir" ]; then
#      if [ -d "$dir/.git" ]; then
#        if [ "$found_start" = false ]; then
#          if [ "$(realpath $dir)" == "$start_from" ]; then
#            found_start=true
#          else
#            echo "Skipping directory $dir"
#            continue
#          fi
#        fi
#        echo "Refreshing git repository in $dir"
#        cd "$dir" || continue
#        refresh_git_repo
#        cd - > /dev/null || exit
#      else
#        find_and_refresh_git_repos_recursively "$dir"
#      fi
#    fi
#  done
#}
#
#
#find_and_refresh_git_repos_recursively "$(pwd)"
