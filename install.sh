#!/usr/bin/env bash

set -ueo pipefail

if [ -n "${CI:-}" ]; then
  # in CI systems, show debug output
  set -x
fi

# Use latest installed nodejs, via asdf
if [ -z "${ASDF_NODEJS_VERSION:-}" ] && [ -n "$(which asdf)" ]; then
  ASDF_NODEJS_VERSION="$(asdf list nodejs | sort | tail -n 1 | xargs || true)"
  export ASDF_NODEJS_VERSION
fi

LB_DIR="${1:-"${HOME}/.lintball"}"

if [ ! -d "$LB_DIR" ]; then
  echo "Cloning elijahr/lintball..."
  git clone \
    --branch "${LINTBALL_VERSION:-"devel"}" \
    --depth 1 \
    https://github.com/elijahr/lintball.git \
    "$LB_DIR" 2>/dev/null
  (
    cd "${LB_DIR}"
    npm install 2>/dev/null
  )
else
  # Update
  echo "lintball already installed, updating..."
  (
    cd "${LB_DIR}"
    git fetch origin
    git add .
    git stash
    git reset --hard "origin/${LINTBALL_VERSION:-"devel"}" 2>/dev/null
    npm install 2>/dev/null
  )
fi

bash_insert="$(
  cat <<EOF
if [ -z "\${LINTBALL_DIR:-}" ]; then
  export LINTBALL_DIR="${LB_DIR}"
  . "${LB_DIR}/lintball.sh"
fi
EOF
)"

# Linux bash
if ! grep -qF "LINTBALL_DIR" "${HOME}/.bashrc"; then
  echo "$bash_insert" >>"${HOME}/.bashrc"
fi
echo "lintball → ${HOME}/.bashrc"

# macOS bash
if ! grep -qF "LINTBALL_DIR" "${HOME}/.bash_profile"; then
  echo "$bash_insert" >>"${HOME}/.bash_profile"
fi
echo "lintball → ${HOME}/.bash_profile"

fish_insert="$(
  cat <<EOF
if test -z "\$LINTBALL_DIR"
  set -gx LINTBALL_DIR "${LB_DIR}"
  source "${LB_DIR}/lintball.fish"
end
EOF
)"

# fish shell
fish_config="${XDG_CONFIG_HOME:-"${HOME}/.config"}/fish/config.fish"
if ! grep -qF "LINTBALL_DIR" "$fish_config"; then
  mkdir -p "$(dirname "$fish_config")"
  echo "$fish_insert" >>"$fish_config"
fi
echo "lintball → $fish_config"

echo
echo "Restart your shell for changes to take effect."
echo
