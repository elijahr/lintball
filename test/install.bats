#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ./lib/test_utils

setup() {
  ORIGINAL_LINTBALL_DIR="$LINTBALL_DIR"
  ORIGINAL_HOME="$HOME"
  LINTBALL_REPO="$(realpath "$(dirname "$BATS_TEST_DIRNAME")")"
  LINTBALL_VERSION="$(git_branch)"
  INSTALL_SH="${LINTBALL_REPO}/install.sh"
  TMP_DIR="$(mktemp -d)"
  HOME="$TMP_DIR"
  unset LINTBALL_DIR
  export ORIGINAL_LINTBALL_DIR ORIGINAL_HOME LINTBALL_REPO LINTBALL_VERSION INSTALL_SH TMP_DIR HOME
}

teardown() {
  rm -rf "$TMP_DIR"
  unset ORIGINAL_LINTBALL_DIR ORIGINAL_HOME LINTBALL_REPO LINTBALL_VERSION INSTALL_SH TMP_DIR

  HOME="$ORIGINAL_HOME"
  LINTBALL_DIR="$ORIGINAL_LINTBALL_DIR"
  export HOME LINTBALL_DIR
}

assert_installed_to() {
  local lintball_dir
  lintball_dir="$1"

  # Should have cloned the repo into the specified place
  assert [ -d "${lintball_dir}/.git" ]

  # bash should have lintball in PATH
  assert_equal "$(bash -c 'cd $HOME; . .bashrc; echo $LINTBALL_DIR')" "$lintball_dir"
  assert_equal "$(bash -c 'cd $HOME; . .bashrc; which lintball')" "${lintball_dir}/bin/lintball"
  run bash -c 'cd $HOME; . .bashrc; lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."

  # fish should have lintball in PATH
  assert_equal "$(fish -c 'echo $LINTBALL_DIR')" "$lintball_dir"
  assert_equal "$(fish -c 'which lintball')" "${lintball_dir}/bin/lintball"
  run fish -c 'lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."

  # zsh should have lintball in PATH
  assert_equal "$(zsh -c 'cd $HOME; . ./.zshrc; echo $LINTBALL_DIR')" "$lintball_dir"
  assert_equal "$(zsh -c 'cd $HOME; . ./.zshrc; which lintball')" "${lintball_dir}/bin/lintball"
  run zsh -c 'cd $HOME; . ./.zshrc; lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

@test "install.sh installs to specific LINTBALL_DIR" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/some/path"

  run "$INSTALL_SH" "$lintball_dir"
  assert_success
  assert_installed_to "$lintball_dir"
}

@test "install.sh installs to default LINTBALL_DIR" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_success
  assert_installed_to "$lintball_dir"
}
