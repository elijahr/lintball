#!/usr/bin/env bash

set -uexo pipefail

LB_DIR="${1:-"${HOME}/.lintball"}"

if [ ! -d "$LB_DIR" ]; then
  git clone \
    --branch "${LINTBALL_VERSION:-"devel"}" \
    --depth 1 \
    https://github.com/elijahr/lintball.git \
    "$LB_DIR"
  (
    cd "${LB_DIR}"
    npm install
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
