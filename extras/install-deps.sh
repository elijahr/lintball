#!/usr/bin/env bash

set -ueo pipefail

EXTRAS_DIR="$(dirname "${BASH_SOURCE[0]}")"
LINTBALL_DIR="$(dirname "$EXTRAS_DIR")"

echo
echo "# Installing piu package manager wrapper"
# piu from https://github.com/keithieopia/piu
curl -o- https://raw.githubusercontent.com/keithieopia/piu/master/piu >"${EXTRAS_DIR}/piu"
chmod +x "${EXTRAS_DIR}/piu"
echo "# piu installed"
echo

PATH="$EXTRAS_DIR:$PATH"

# Try to get more up to date requirements from brew, since brew
# is available on both macOS and Github Actions' Ubuntu, and brew
# has more up to date versions.
if [ -n "$(which brew)" ]; then
  brew install shfmt shellcheck nim python3 ruby node.js
else
  all_deps=("shfmt" "shellcheck" "nim" "python3" "ruby")
  deps=()
  for dep in "${all_deps[@]}"; do
    if [ -z "$(which "$dep")" ]; then
      echo "# $dep: not found, will install"
      deps+=("$dep")
    fi
  done
  if [ -z "$(which node)" ]; then
    echo "# nodejs: not found, will install"
    deps+=("nodejs")
  fi
  if [ "${#deps[@]}" -gt 0 ]; then
    eval "piu i ${deps[*]}"
  fi
fi
echo "# System packages installed"
echo

cd "$LINTBALL_DIR"

echo
echo "# Installing Node requirements..."
npm install
echo "# Node requirements installed"
echo

echo
echo "# Installing Ruby requirements..."
gem install rubocop || sudo gem install rubocop
echo "# Ruby requirements installed"
echo

if [ -z "$(which pip)" ] && [ -z "$(which pip3)" ]; then
  echo "# pip: not found, installing..."
  curl -o- https://bootstrap.pypa.io/get-pip.py >"${EXTRAS_DIR}/get-pip.py"
  python3 "${EXTRAS_DIR}/get-pip.py" || sudo python3 "${EXTRAS_DIR}/get-pip.py"
fi

echo
echo "# Installing Python requirements..."
if [ -n "$(which apt-get)" ]; then
  piu i python3-setuptools
fi
if [ -z "$(which pip3)" ]; then
  pip install wheel || sudo pip install wheel
  pip install -r requirements.txt || sudo pip install -r requirements.txt
else
  pip3 install wheel || sudo pip3 install wheel
  pip3 install -r requirements.txt || sudo pip3 install -r requirements.txt
fi
echo "# Python requirements installed"
echo

echo "# lintball dependencies installed"
echo
