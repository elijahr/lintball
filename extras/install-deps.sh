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

echo
echo "# Installing system packages: ${deps[*]}"
piu c
deps=()

# Try to get a more up to date requirements from brew
if [ -n "$(which brew)" ]; then
  brew install shfmt shellcheck nim
else
  deps+=("shellcheck" "shfmt" "nim")
fi

if [ -z "$(which python3)" ]; then
  echo "# python3: not found, will install"
  deps+=("python3")
else
  echo "# python3: found"
fi

if [ -z "$(which ruby)" ]; then
  echo "# ruby: not found, will install"
  deps+=("ruby")
else
  echo "# ruby: found"
fi

if [ -z "$(which node)" ]; then
  echo "# node: not found, will install"
  deps+=("nodejs")
else
  echo "# node: found"
fi

if [ "${#deps[@]}" -gt 0 ]; then
  eval "piu i ${deps[*]}"
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
