#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ../lib/utils
load ./lib/test_utils

setup() {
  setup_test
  git init .
}

teardown() {
  teardown_test
}

@test "install-lintball-githooks sans arg" {
  run install-lintball-githooks
  assert_success
  assert_equal "$(git --git-dir="${PROJECT_DIR}/.git" config --local core.hooksPath)" "$LINTBALL_DIR/githooks"
}

@test "install-lintball-githooks with arg" {
  tmp="$(mktemp -d)"
  git init "$tmp"
  run install-lintball-githooks "$tmp"
  assert_success
  assert_equal "$(git --git-dir="${tmp}/.git" config --local core.hooksPath)" "$LINTBALL_DIR/githooks"
  rm -rf "$tmp"
}

@test "install-lintball-githooks already configured" {
  run install-lintball-githooks
  run install-lintball-githooks
  assert_failure
}

@test "install-lintball-githooks copies lintball-ignore.default → .lintball-ignore" {
  assert [ ! -f ".lintball-ignore" ]
  run install-lintball-githooks
  assert_success
  assert [ -f ".lintball-ignore" ]
  assert_equal "$(cat .lintball-ignore)" "$(cat "${LINTBALL_DIR}/lintball-ignore.defaults")"
}

@test "install-lintball-githooks does not overwrite existing .lintball-ignore" {
  echo "custom" >".lintball-ignore"
  run install-lintball-githooks
  assert_success
  assert [ -f ".lintball-ignore" ]
  assert_equal "$(cat .lintball-ignore)" "custom"
}
