install_bundler_requirements() {
  if [ -z "$(which bundle)" ] && [ -n "$(which gem)" ]; then
    gem install bundler || sudo gem install bundler
  fi
  if [ -n "$(which bundle)" ]; then
    (
      cd "${LINTBALL_DIR}/deps"
      bundle config set --local deployment 'true'
      bundle install
    )
  else
    echo "Error: cannot install bundler requirements - could not find a bundle executable." >&2
    echo "If ruby is installed, try gem install bundler and re-run this script." >&2
    return 1
  fi
}

install_clippy() {
  if [ -n "$(which cargo)" ]; then
    if [ -z "$(which rustup)" ]; then
      # Install rustup
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    else
      rustup self update
      rustup update
    fi
    rustup component add clippy
    # nightly is needed for clippy to fix issues
    rustup toolchain install nightly
  else
    echo "Error: cannot install clippy - could not find a cargo executable." >&2
    return 1
  fi
}

install_pip_requirements() {
  local pyexe
  pyexe=""
  if [ ! -d "${LINTBALL_DIR}/deps/python-env" ]; then
    if [ -n "$(which python3)" ]; then
      pyexe="python3"
    elif [ -n "$(which python)" ]; then
      if python -c "import sys; sys.exit(0 if sys.version_info >= (3,3,0) else 1)"; then
        pyexe="python"
      fi
    fi
    if [ -n "$pyexe" ]; then
      "$pyexe" -m venv "${LINTBALL_DIR}/deps/python-env"
    else
      echo "Error: cannot install pip requirements." >&2
      echo "could not find a suitable Python version (>=3.3.0)." >&2
      return 1
    fi
  fi

  "${LINTBALL_DIR}/deps/python-env/bin/pip" install -r "${LINTBALL_DIR}/deps/requirements-pip.txt"
}

install_shell_tools() {
  packages=()
  if [ -z "$(which shellcheck)" ]; then
    packages+=("shellcheck")
  fi
  packages=()
  if [ -z "$(which shfmt)" ]; then
    packages+=("shfmt")
  fi
  if [ "${#packages[@]}" -gt 0 ]; then
    if [ -n "$(which brew)" ]; then
      brew update
      brew install "${packages[*]}"
    elif [ -n "$(which apt-get)" ]; then
      sudo apt-get update
      if [ "$answer" = "$answer=yes" ]; then
        sudo apt-get install -y "${packages[*]}"
      else
        sudo apt-get install "${packages[*]}"
      fi
    elif [ -n "$(which pacman)" ]; then
      sudo pacman -Syu "${packages[*]}"
    elif [ -n "$(which apk)" ]; then
      apk --update add "${packages[*]}"
    else
      echo "Error: cannot install requirements: ${packages[*]}" >&2
      echo "Try installing manually." >&2
      return 1
    fi
  fi
}

install_stylua() {
  if [ -n "$(which cargo)" ]; then
    cargo install stylua --features luau
  else
    echo "Error: cannot install stylua - could not find a cargo executable." >&2
    return 1
  fi
}

install_uncrustify() {
  local answer
  answer="$1"
  if [ -n "$(which brew)" ]; then
    brew update
    brew install uncrustify
  elif [ -n "$(which apt-get)" ]; then
    sudo apt-get update
    if [ "$answer" = "$answer=yes" ]; then
      sudo apt-get install -y uncrustify
    else
      sudo apt-get install uncrustify
    fi
  elif [ -n "$(pacman)" ]; then
    sudo pacman -Syu uncrustify
  elif [ -n "$(which apk)" ]; then
    apk --update add uncrustify
  else
    echo "Error: cannot install requirements: uncrustify" >&2
    echo "Try installing manually." >&2
    return 1
  fi
}

validate_nimpretty() {
  if [ -z "$(which nimpretty)" ]; then
    echo "Error: nimpretty not found." >&2
    echo "nimpretty is included with Nim. Try installing a Nim release manually." >&2
    return 1
  fi
}
