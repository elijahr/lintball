#!/usr/bin/env bats

load ../tools/node_modules/bats-support/load
load ../tools/node_modules/bats-assert/load
load ./lib/test_utils

setup() {
  setup_test
  git init .
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
  git init "${tmp}"
  run lintball install-githooks --no --path "${tmp}"
  assert_success
  assert_equal "$(git --git-dir="${tmp}/.git" config --local core.hooksPath)" "${tmp}/.githooks"
  assert [ -x "${tmp}/.githooks/pre-commit" ]
  rm -rf "${tmp}"
}

@test 'lintball install-githooks already configured' {
  run lintball install-githooks --no
  run lintball install-githooks --no
  assert_failure
}

@test 'lintball install-githooks does not cause shellcheck errors' {
  run lintball install-githooks --no
  run lintball check .githooks
  assert_success
}
