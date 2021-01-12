#!/usr/bin/env bash

export LINTBALL_DIR="${LINTBALL_DIR:-"${HOME}/.lintball"}"

# Add to path
export PATH="${LINTBALL_DIR}/bin:$PATH"

# Add to path in Github Actions
if [ -n "${GITHUB_PATH:-}" ]; then
  echo "${LINTBALL_DIR}/bin" >>"$GITHUB_PATH"
fi
