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

@test "lintball githooks sans arg" {
  run lintball githooks --no
  assert_success
  assert_equal "$(git --git-dir="${TEST_PROJECT_DIR}/.git" config --local core.hooksPath)" "${TEST_PROJECT_DIR}/.githooks"
  assert [ -x "${TEST_PROJECT_DIR}/.githooks/pre-commit" ]
}

@test "lintball githooks with arg" {
  tmp="$(mktemp -d)"
  git init "$tmp"
  run lintball githooks --no "$tmp"
  assert_success
  assert_equal "$(git --git-dir="${tmp}/.git" config --local core.hooksPath)" "${tmp}/.githooks"
  assert [ -x "${tmp}/.githooks/pre-commit" ]
  rm -rf "$tmp"
}

@test "lintball githooks already configured" {
  run lintball githooks --no
  run lintball githooks --no
  assert_failure
}

@test "lintball githooks does not cause shellcheck errors" {
  run lintball githooks --no
  run lintball check .githooks
  assert_success
}
