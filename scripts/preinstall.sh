#!/usr/bin/env bash

if [ -z "$(which shellcheck)" ] || [ -z "$(which shfmt)" ]; then
  if [ -n "$(which shellcheck)" ]; then
    echo >&2
    echo "Warning: shfmt not installed on this system." >&2
    echo "lintball will not be able to check/fix shell scripts without" >&2
    echo "shfmt." >&2
    echo >&2
  elif [ -n "$(which shfmt)" ]; then
    echo >&2
    echo "Warning: shellcheck not installed on this system." >&2
    echo "lintball will not be able to check/fix shell scripts without" >&2
    echo "shellcheck." >&2
    echo >&2
  else
    echo >&2
    echo "Warning: shellcheck and shfmt not installed on this system." >&2
    echo "lintball will not be able to check/fix shell scripts without" >&2
    echo "shellcheck and shfmt." >&2
    echo >&2
  fi
fi

pyexe=""
if [ ! -d "${LB_DIR}/deps/python-env" ]; then
  if [ -n "$(which python3)" ]; then
    pyexe="python3"
  elif [ -n "$(which python)" ]; then
    if python -c "import sys; sys.exit(0 if sys.version_info >= (3,3,0) else 1)"; then
      pyexe="python"
    fi
  fi
  if [ -n "$pyexe" ]; then
    "$pyexe" -m venv "${LB_DIR}/deps/python-env"
  else
    echo "Warning: cannot install pip requirements." >&2
    echo "could not find a suitable Python version (>=3.3.0)." >&2
  fi
fi

if [ -f "${LB_DIR}/deps/python-env/bin/pip" ]; then
  "${LB_DIR}/deps/python-env/bin/pip" install -r "${LB_DIR}/deps/requirements-pip.txt"
fi

if [ -n "$(which bundle)" ]; then
  (
    cd "${LB_DIR}/deps"
    BUNDLE_GEMFILE="${LB_DIR}/deps/Gemfile"
    export BUNDLE_GEMFILE
    bundle config set --local deployment 'true'
    bundle install
  )
else
  echo "Warning: cannot install bundler requirements - could not find a bundle executable." >&2
  echo "If ruby is installed, try gem install bundler and re-run this script." >&2
fi

if [ -n "$(which cargo)" ]; then
  cargo install stylua --features luau
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
  echo "Warning: cannot install cargo requirements - could not find an cargo executable." >&2
fi
