#!/usr/bin/env bash
# shellcheck disable=SC2143

set -ueo pipefail

if [ -n "${CI:-}" ]; then
  # on CI systems show debug output
  set -x
fi

LB_DIR="${1:-"${HOME}/.lintball"}"
LINTBALL_REPO="${LINTBALL_REPO:-"https://github.com/elijahr/lintball.git"}"

update_lintball() {

  if [ ! -d "$LB_DIR" ]; then
    echo "cloning lintball → ${LB_DIR}…"
    git clone "$LINTBALL_REPO" "$LB_DIR" 2>/dev/null
  else
    # Update
    echo "lintball already installed in ${LB_DIR}, updating…"
  fi

  (
    local version
    cd "$LB_DIR"

    version="${LINTBALL_VERSION:-"$(git ls-remote --tags "$LINTBALL_REPO" | awk '{ print $2 }' | sort | tail -n1)"}"

    # Strip ref info
    version="${version//refs\/heads\//}"
    version="${version//refs\/tags\//}"
    version="${version//refs\/remotes\/origin\//}"

    git fetch origin
    git fetch origin --tags
    git stash 1>/dev/null

    if [ -n "$(git ls-remote "$LINTBALL_REPO" | grep -F "refs/heads/$version")" ]; then
      # branch
      git reset --hard "origin/$version"
    else
      # must be an sha or tag
      version="$version"
      git reset --hard "$version"
    fi

    echo "lintball updated to $version"
  )
}

update_deps() {
  (
    cd "$LB_DIR"

    if [ -z "$(which shellcheck)" ]; then
      echo -e
      echo -e "Warning: shellcheck not installed on this system."
      echo -e "lintball will not be able to lint shell scripts without"
      echo -e "shellcheck."
      echo -e
    fi

    if [ -z "$(which shfmt)" ]; then
      echo -e
      echo -e "Warning: shfmt not installed on this system."
      echo -e "lintball will not be able to lint shell scripts without"
      echo -e "shfmt."
      echo -e
    fi

    local pyexe
    if [ ! -d "${LB_DIR}/python-env" ]; then
      if [ -n "$(which python3)" ]; then
        pyexe="python3"
      elif [ -n "$(which python)" ]; then
        if python -c "import sys; sys.exit(0 if sys.version_info >= (3,3,0) else 1)"; then
          pyexe="python"
        fi
      fi
      if [ -n "$pyexe" ]; then
        "$pyexe" -m venv "python-env"
      else
        echo -e "Warning: cannot install pip requirements - could not find a suitable Python version (>=3.3.0)."
      fi
    fi

    if [ -f "${LB_DIR}/python-env/bin/pip" ]; then
      python-env/bin/pip install -r requirements-pip.txt
    fi

    if [ -n "$(which npm)" ]; then
      npm install
    else
      echo -e "Warning: cannot install npm requirements - could not find an npm executable."
    fi

    if [ -n "$(which bundle)" ]; then
      bundle config set --local deployment 'true'
      bundle install
    else
      echo -e "Warning: cannot install bundler requirements - could not find a bundle executable."
      echo -e "If ruby is installed, try gem install bundler and re-run this script."
    fi
  )
}

add_inits() {
  local posix_insert fish_insert fish_config

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
  if ! grep -qF "LINTBALL_DIR" "${HOME}/.bashrc"; then
    echo "$posix_insert" >>"${HOME}/.bashrc"
  fi
  echo "lintball → ${HOME}/.bashrc"

  if ! grep -qF "LINTBALL_DIR" "${HOME}/.bash_profile"; then
    echo "$posix_insert" >>"${HOME}/.bash_profile"
  fi
  echo "lintball → ${HOME}/.bash_profile"

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
}

update_lintball
update_deps
add_inits
