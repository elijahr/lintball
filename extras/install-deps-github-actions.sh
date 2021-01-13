#!/usr/bin/env bash

set -ueo pipefail

EXTRAS_DIR="$(dirname "${BASH_SOURCE[0]}")"
LINTBALL_DIR="$(dirname "$EXTRAS_DIR")"

PATH="$EXTRAS_DIR:$PATH"

# Get more up to date requirements from brew, since brew
# is available on both macOS and Github Actions' Ubuntu, and brew
# has more up to date versions.
brew install shfmt shellcheck nim python3
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
sudo gem install rubocop
echo "# Ruby requirements installed"
echo

echo
echo "# Installing Python requirements..."
sudo pip3 install -r requirements.txt
echo "# Python requirements installed"
echo

echo "# lintball dependencies installed"
echo
