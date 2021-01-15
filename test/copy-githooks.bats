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

@test "lintball copy-githooks sans arg" {
  run lintball copy-githooks --no
  assert_success
  assert_equal "$(git --git-dir="${PROJECT_DIR}/.git" config --local core.hooksPath)" "${PROJECT_DIR}/.githooks"
  assert [ -x "${PROJECT_DIR}/.githooks/pre-commit" ]
}

@test "lintball copy-githooks with arg" {
  tmp="$(mktemp -d)"
  git init "$tmp"
  run lintball copy-githooks --no "$tmp"
  assert_success
  assert_equal "$(git --git-dir="${tmp}/.git" config --local core.hooksPath)" "${tmp}/.githooks"
  assert [ -x "${tmp}/.githooks/pre-commit" ]
  rm -rf "$tmp"
}

@test "lintball copy-githooks already configured" {
  run lintball copy-githooks --no
  run lintball copy-githooks --no
  assert_failure
}
