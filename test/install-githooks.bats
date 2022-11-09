#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ./lib/test_utils

setup_file() {
  clear_lock git
}

teardown_file() {
  clear_lock git
}

setup() {
  setup_test
  get_lock git
  git init .
  clear_lock git
}

teardown() {
  teardown_test
}

@test 'lintball install-githooks without --path' {
  run lintball install-githooks --no
  assert_success
  assert_equal "$(git --git-dir="${TEST_PROJECT_DIR}/.git" config --local core.hooksPath)" "${TEST_PROJECT_DIR}/.githooks"
  assert [ -x "${TEST_PROJECT_DIR}/.githooks/pre-commit" ]
}

@test 'lintball install-githooks with --path' {
  tmp="$(mktemp -d)"
  get_lock git
  git init "$tmp"
  run lintball install-githooks --no --path "$tmp"
  assert_success
  assert_equal "$(git --git-dir="${tmp}/.git" config --local core.hooksPath)" "${tmp}/.githooks"
  assert [ -x "${tmp}/.githooks/pre-commit" ]
  rm -rf "$tmp"
  clear_lock git
}

@test 'lintball install-githooks already configured' {
  get_lock git
  run lintball install-githooks --no
  run lintball install-githooks --no
  clear_lock git
  assert_failure
}

@test 'lintball install-githooks does not cause shellcheck errors' {
  get_lock git
  run lintball install-githooks --no
  run lintball check .githooks
  clear_lock git
  assert_success
}
