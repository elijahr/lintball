#!/usr/bin/env bats

load ../deps/node_modules/bats-support/load
load ../deps/node_modules/bats-assert/load
load ./lib/test_utils

setup() {
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
  export ORIGINAL_HOME LINTBALL_REPO LINTBALL_VERSION INSTALL_SH TMP_DIR HOME PATH
}

teardown() {
  rm -rf "$TMP_DIR"
  unset ORIGINAL_HOME LINTBALL_REPO LINTBALL_VERSION INSTALL_SH TMP_DIR

  HOME="$ORIGINAL_HOME"
  LINTBALL_DIR="$PROJECT_DIR"
  export HOME LINTBALL_DIR

  PATH="$ORIGINAL_PATH"
  export PATH
}

assert_bash_init() {
  local install_dir
  install_dir="$1"

  # bash should have lintball in PATH
  assert_equal "$(bash -c 'cd $HOME; . .bashrc; echo $LINTBALL_DIR')" "$install_dir"
  assert_equal "$(bash -c 'cd $HOME; . .bashrc; which lintball')" "${install_dir}/bin/lintball"
  run bash -c 'cd $HOME; . .bashrc; lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

assert_fish_init() {
  local install_dir
  install_dir="$1"

  # fish should have lintball in PATH
  assert_equal "$(fish -c 'echo $LINTBALL_DIR')" "$install_dir"
  assert_equal "$(fish -c 'which lintball')" "${install_dir}/bin/lintball"
  run fish -c 'lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

assert_zsh_init() {
  local install_dir
  install_dir="$1"

  # zsh should have lintball in PATH
  assert_equal "$(zsh -c 'cd $HOME; . ./.zshrc; echo $LINTBALL_DIR')" "$install_dir"
  assert_equal "$(zsh -c 'cd $HOME; . ./.zshrc; which lintball')" "${install_dir}/bin/lintball"
  run zsh -c 'cd $HOME; . ./.zshrc; lintball --help'
  assert_success
  assert_line "lintball: keep your project tidy with one command."
}

assert_git() {
  local install_dir expected_version
  install_dir="$1"
  expected_version="${2:-$LINTBALL_VERSION}"

  # Should have cloned the repo
  assert [ -d "${install_dir}/.git" ]
  assert_equal \
    "$(git --git-dir="${install_dir}/.git" remote show origin | head -n2 | tail -n1 | awk '{ print $3 }')" \
    "$LINTBALL_REPO"
  assert_equal \
    "$(git --git-dir="${install_dir}/.git" rev-parse HEAD)" \
    "$(git --git-dir="${PROJECT_DIR}/.git" rev-parse "$expected_version")"
}

@test "install.sh installs to specific LINTBALL_DIR" {
  local install_dir

  install_dir="${TMP_DIR}/some/path"

  run "$INSTALL_SH" "$install_dir"
  assert_success
  assert_git "$install_dir"
}

@test "install.sh installs to default LINTBALL_DIR" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_success
  assert_git "$install_dir"
}

@test "install.sh defaults to latest remote tag" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"
  unset LINTBALL_VERSION
  run "$INSTALL_SH"
  assert_success
  assert_git "$install_dir" "$(git --git-dir="${PROJECT_DIR}/.git" tag | sort | tail -n1)"
}

@test "install.sh can install a specific commit" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"
  LINTBALL_VERSION="$(git_sha)"
  export LINTBALL_VERSION
  run "$INSTALL_SH"
  assert_success
  assert_git "$install_dir" "$(git_sha)"
}

@test "install.sh can install a specific branch" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"
  LINTBALL_VERSION="$(git_branch)"
  export LINTBALL_VERSION
  run "$INSTALL_SH"
  assert_success
  assert_git "$install_dir" "$(git_branch)"
}

@test "install.sh installs bash initialization" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_bash_init "$install_dir"
}

@test "install.sh installs fish initialization" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_fish_init "$install_dir"
}

@test "install.sh installs zsh initialization" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert_zsh_init "$install_dir"
}

@test "install.sh updates an existing installation" {
  if [[ ${GITHUB_REF:-} =~ ^refs/tags/ ]]; then
    # TODO: fix; test acts wonky on tags on GitHub Actions, but updating an
    # existing installation works fine. Probably has to do with how the
    # actions/checkout Github Action behaves for tags.
    skip
  fi

  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  (
    cd "$install_dir"
    git checkout -b "test-test-test"
    touch foo
    git add foo
    git config --global user.email "hamburglar@example.com"
    git config --global user.name "The Hamburglar"
    git commit -m "testing"
  )
  run "$INSTALL_SH"
  assert_success
  assert_equal \
    "$(git --git-dir="${install_dir}/.git" rev-parse HEAD)" \
    "$(git_sha)"
}

@test "install.sh installs pip packages" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert [ -d "${install_dir}/python-env" ]
  run "${install_dir}/python-env/bin/python" -c \
    "import autoflake, autopep8, black, docformatter, isort, yamllint"
  assert_success
}

@test "install.sh installs npm packages" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert [ -d "${install_dir}/node_modules/prettier" ]
  assert [ -d "${install_dir}/node_modules/prettier-eslint-cli" ]
}

@test "install.sh installs bundler packages" {
  local install_dir

  install_dir="${TMP_DIR}/.lintball"

  run "$INSTALL_SH"
  assert [ -f "${install_dir}/vendor/bundle/ruby/3.0.0/gems/rubocop-1.8.1/exe/rubocop" ]
}
