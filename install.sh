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
set -- "${args[@]}" # restore positional parameters

if [ "$LINTBALL_INSTALL_DEPS" = "yes" ]; then
  pip install black autopep8 isort autoflake docformatter
  (
    cd ~/.lintball
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
    exit 1
  fi
  exit 0
fi


LB_DIR="${1:-"${HOME}/.lintball"}"

if [ ! -d "$LB_DIR" ]; then
  echo "Cloning elijahr/lintball..."
  git clone \
    --branch "${LINTBALL_VERSION:-"devel"}" \
    --depth 1 \
    https://github.com/elijahr/lintball.git \
    "$LB_DIR" 2>/dev/null
else
  # Update
  echo "lintball already installed, updating..."
  (
    cd "${LB_DIR}"
    git fetch origin
    git add .
    git stash
    git reset --hard "origin/${LINTBALL_VERSION:-"devel"}" 2>/dev/null
    if [ -d "node_modules" ]; then
      # User has installed the node modules, so update them
      npm install 2>/dev/null
    fi
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

# Add to path in Github Actions
if [ -n "${GITHUB_PATH:-}" ]; then
  echo "${LB_DIR}/bin" >>"$GITHUB_PATH"
fi

echo
echo "Restart your shell for changes to take effect."
echo
