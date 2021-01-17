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

  # symlink caches for faster runs
  ln -s "${ORIGINAL_HOME}/.cache" "${HOME}/.cache"
  ln -s "${ORIGINAL_HOME}/.npm" "${HOME}/.npm"

  # Remove anything from path in ORIGINAL_HOME; version managers that use shims,
  # such as asdf, will break because we have mocked HOME.
  PATH="$(echo "$PATH" | sed "s|${ORIGINAL_HOME}[^:]\{1,\}:||g")"

  unset LINTBALL_DIR
  export ORIGINAL_LINTBALL_DIR ORIGINAL_HOME LINTBALL_REPO LINTBALL_VERSION INSTALL_SH TMP_DIR HOME PATH
}

teardown() {
  rm -rf "$TMP_DIR"
  unset ORIGINAL_LINTBALL_DIR ORIGINAL_HOME LINTBALL_REPO LINTBALL_VERSION INSTALL_SH TMP_DIR

  HOME="$ORIGINAL_HOME"
  LINTBALL_DIR="$ORIGINAL_LINTBALL_DIR"
  export HOME LINTBALL_DIR

  PATH="$ORIGINAL_PATH"
  export PATH
}

assert_bash_init() {
  local lintball_dir
  lintball_dir="$1"

  # bash should have lintball in PATH
  assert_equal "$(bash -c 'cd $HOME; . .bashrc; echo $LINTBALL_DIR')" "$lintball_dir"
  assert_equal "$(bash -c 'cd $HOME; . .bashrc; which lintball')" "${lintball_dir}/bin/lintball"
  run bash -c 'cd $HOME; . .bashrc; lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

assert_fish_init() {
  local lintball_dir
  lintball_dir="$1"

  # fish should have lintball in PATH
  assert_equal "$(fish -c 'echo $LINTBALL_DIR')" "$lintball_dir"
  assert_equal "$(fish -c 'which lintball')" "${lintball_dir}/bin/lintball"
  run fish -c 'lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

assert_zsh_init() {
  local lintball_dir
  lintball_dir="$1"

  # zsh should have lintball in PATH
  assert_equal "$(zsh -c 'cd $HOME; . ./.zshrc; echo $LINTBALL_DIR')" "$lintball_dir"
  assert_equal "$(zsh -c 'cd $HOME; . ./.zshrc; which lintball')" "${lintball_dir}/bin/lintball"
  run zsh -c 'cd $HOME; . ./.zshrc; lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

assert_git() {
  local lintball_dir
  lintball_dir="$1"

  # Should have cloned the repo
  assert [ -d "${lintball_dir}/.git" ]
  assert_equal "$(git --git-dir="${lintball_dir}/.git" remote show origin | head -n2 | tail -n1 | awk '{ print $3 }')" "$LINTBALL_REPO"
  assert_equal "$(git --git-dir="${lintball_dir}/.git" rev-parse --abbrev-ref HEAD)" "$LINTBALL_VERSION"
}

@test "install.sh installs to specific LINTBALL_DIR" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/some/path"

  run "$INSTALL_SH" "$lintball_dir"
  assert_success
  assert_git "$lintball_dir"
}

@test "install.sh installs to default LINTBALL_DIR" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_success
  assert_git "$lintball_dir"
}

@test "install.sh installs bash initialization" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_bash_init "$lintball_dir"
}

@test "install.sh installs fish initialization" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_fish_init "$lintball_dir"
}

@test "install.sh installs zsh initialization" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_zsh_init "$lintball_dir"
}

@test "install.sh updates an existing installation" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  (
    cd "$lintball_dir"
    git checkout -b "test123"
    git reset --hard HEAD^1
  )
  run "$INSTALL_SH"
  assert_success
  assert_equal "$(git --git-dir="${lintball_dir}/.git" rev-parse HEAD)" "$(git_sha)"
}

@test "install.sh installs pip packages" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert [ -d "${lintball_dir}/python-env" ]
  run "${lintball_dir}/python-env/bin/python" -c \
    "import autoflake, autopep8, black, docformatter, isort, yamllint"
  assert_success
}

@test "install.sh installs npm packages" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert [ -d "${lintball_dir}/node_modules/prettier" ]
  assert [ -d "${lintball_dir}/node_modules/prettier-eslint-cli" ]
}

@test "install.sh installs bundler packages" {
  local lintball_dir

  lintball_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert [ -f "${lintball_dir}/vendor/bundle/ruby/3.0.0/gems/rubocop-1.8.1/exe/rubocop" ]
}
