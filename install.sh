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

LINTBALL_INSTALL_DEPS="no"
args=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    --deps)
      LINTBALL_INSTALL_DEPS="yes"
      shift
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

if [ "${#args[@]}" -gt 0 ]; then
  set -- "${args[@]}" # restore positional parameters
fi

LB_DIR="${1:-"${HOME}/.lintball"}"
LINTBALL_VERSION="${LINTBALL_VERSION:-"refs/heads/devel"}"

if [ ! -d "$LB_DIR" ]; then
  echo "cloning lintball → ${LB_DIR}…"
  git clone https://github.com/elijahr/lintball.git "$LB_DIR" 2>/dev/null
else
  # Update
  echo "lintball already installed, updating…"
fi

(
  cd "${LB_DIR}"
  git fetch origin --tags
  sha="$(git show-ref "$LINTBALL_VERSION" | awk '{ print $1 }')"
  git stash
  git checkout "$sha" 2>/dev/null
  if [ -d "node_modules" ]; then
    # User has installed the node modules, so update them
    npm install 2>/dev/null
  fi
  if [ -d "vendor" ]; then
    # User has installed the node modules, so update them
    bundle install 2>/dev/null
  fi
)

if [ "$LINTBALL_INSTALL_DEPS" = "yes" ]; then
  pip3 install black autopep8 isort autoflake docformatter yamllint
  if [ -z "$(which bundler)" ]; then
    gem install bundler || sudo gem install bundler
  fi
  bundle install
  (
    cd "$LB_DIR"
    npm install
  )
  if [ -n "$(which brew)" ]; then
    brew install shfmt shellcheck
  elif [ -z "$(which apt-get)" ]; then
    if [ -z "$(which shfmt)" ]; then
      sudo apt-get update
      sudo apt-get install -y shfmt
    fi
    if [ -z "$(which shellcheck)" ]; then
      scversion="stable"
      wget -qO- "https://github.com/koalaman/shellcheck/releases/download/${scversion?}/shellcheck-${scversion?}.linux.x86_64.tar.xz" | tar -xJv
      cp "shellcheck-${scversion}/shellcheck" /usr/bin/
    fi
  else
    echo -e "Neither brew nor apt-get were found on your system."
    echo -e "You will need to install shfmt and shellcheck manually."
  fi
fi

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
