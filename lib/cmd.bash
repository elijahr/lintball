#!/usr/bin/env bash

set -ueo pipefail

SCRIPTDIR="$(dirname "${BASH_SOURCE[0]}")"

# shellcheck source=SCRIPTDIR/utils.bash
source "${SCRIPTDIR}/utils.bash"

export LINTBALL_STAGED_ONLY="no"

usage() {
  local script_name
  script_name="$(basename "$0")"
  echo -e
  echo -e "Usage: $script_name [options] [path]"
  echo -e
  echo -e "Options:"
  echo -e "  -h|--help"
  echo -e "      Show this help message and exit."
  echo -e
  echo -e "  -x|--exclude PATTERN"
  echo -e "      Exclude paths matching this pattern from being linted."
  echo -e "      Patterns must be parseable by find's -path argument."
  echo -e
  if [ "$script_name" = "fix-all" ]; then
    echo -e "  -s|--fully-staged-only"
    echo -e "      Only fix files which are completely in the git index."
    echo -e
  fi
}

args=()
excludes=("*/\.git/*" "*/\.hg/*" "*/node_modules/*" "*/.next/*" "*/.serverless_nextjs/*" "*/__pycache__/*" "${LINTBALL_EXCLUDES:-}")
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h | --help)
      usage
      exit 0
      ;;
    -s | --full-staged-only)
      LINTBALL_STAGED_ONLY="yes"
      shift # past argument
      ;;
    -x | --exclude)
      excludes+=("$2")
      shift # past argument
      shift # past value
      ;;
    -x=*)
      excludes+=("${1//-x=/}")
      shift # past argument
      ;;
    --exclude=*)
      excludes+=("${1//--exclude=/}")
      shift # past argument
      ;;
    -*)
      echo -e "Unknown switch $1"
      usage
      exit 1
      ;;
    *)             # unknown option
      args+=("$1") # save it in an array for later
      shift        # past argument
      ;;
  esac
done
set -- "${args[@]}" # restore positional parameters

find_cmd="find \"${1:-.}\" -type f"

for exclude in "${excludes[@]}"; do
  if [ -n "$exclude" ]; then
    find_cmd="$find_cmd -a \( -not -path '$exclude' \)"
  fi
done
