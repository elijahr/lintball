#!/usr/bin/env bash

set -ueo pipefail

EXTRAS_DIR="$(dirname "${BASH_SOURCE[0]}")"
LINTBALL_DIR="$(dirname "$EXTRAS_DIR")"

cd "$LINTBALL_DIR"

echo
echo "# Installing Node requirements..."
npm install
echo "# Node requirements installed"
echo

echo
echo "# Installing Ruby requirements..."
gem install rubocop
echo "# Ruby requirements installed"
echo

echo
echo "# Installing Python requirements..."
pip install -r requirements.txt
echo "# Python requirements installed"
echo

if [ -n "$(which asdf)" ]; then
  asdf reshim
fi

echo "# lintball dependencies installed"
echo
