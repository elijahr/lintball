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
LINTBALL_VERSION="${LINTBALL_VERSION:-"refs/heads/devel"}"

if [ ! -d "$LB_DIR" ]; then
  echo "cloning lintball → ${LB_DIR}…"
  git clone https://github.com/elijahr/lintball.git "$LB_DIR" 2>/dev/null
else
  # Update
  echo "lintball already installed in ${LB_DIR}, updating…"
fi

(
  cd "${LB_DIR}"
  git fetch origin "$LINTBALL_VERSION"
  if [[ $LINTBALL_VERSION =~ ^refs/ ]]; then
    git show-ref
    echo "git show-ref origin ""$LINTBALL_VERSION"" is $(git show-ref origin "$LINTBALL_VERSION")"
    sha="$(git show-ref origin "$LINTBALL_VERSION" | awk '{ print $1 }')"
  else
    sha="$LINTBALL_VERSION"
  fi
  git stash 1>/dev/null
  git checkout "$sha" 2>/dev/null
)

echo "lintball updated to $(
  cd "$LB_DIR"
  git show-ref origin "$LINTBALL_VERSION" | awk '{ print $1 }'
)"

posix_insert="$(
  cat <<EOF
if [ -z "\${LINTBALL_DIR:-}" ]; then
  export LINTBALL_DIR="${LB_DIR}"
  . "\${LINTBALL_DIR}/lintball.sh"
fi
EOF
)"

echo

# bash
if [ -f "${HOME}/.bashrc" ]; then
  if ! grep -qF "LINTBALL_DIR" "${HOME}/.bashrc"; then
    echo "$posix_insert" >>"${HOME}/.bashrc"
  fi
  echo "lintball → ${HOME}/.bashrc"
elif [ -f "${HOME}/.bash_profile" ]; then
  if ! grep -qF "LINTBALL_DIR" "${HOME}/.bash_profile"; then
    echo "$posix_insert" >>"${HOME}/.bash_profile"
  fi
  echo "lintball → ${HOME}/.bash_profile"
fi

# zsh
if ! grep -qF "LINTBALL_DIR" "${HOME}/.zshrc"; then
  echo "$posix_insert" >>"${HOME}/.zshrc"
fi
echo "lintball → ${HOME}/.zshrc"

fish_insert="$(
  cat <<EOF
if test -z "\$LINTBALL_DIR"
  set -gx LINTBALL_DIR "${LB_DIR}"
  source "\$LINTBALL_DIR/lintball.fish"
end
EOF
)"

# fish
fish_config="${XDG_CONFIG_HOME:-"${HOME}/.config"}/fish/config.fish"
if ! grep -qF "LINTBALL_DIR" "$fish_config"; then
  mkdir -p "$(dirname "$fish_config")"
  echo "$fish_insert" >>"$fish_config"
fi
echo "lintball → $fish_config"

# Add to path in Github Actions
if [ -n "${GITHUB_PATH:-}" ]; then
  echo "${LB_DIR}/bin" >>"$GITHUB_PATH"
fi

echo
echo "Restart your shell for changes to take effect."
echo
