#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ../lib/utils
load ./lib/test_utils

setup() {
  setup_test
}

teardown() {
  teardown_test
}

@test "check-all yml" {
  run check-all ".github"
  assert_failure
  run fix-all ".github"
  run check-all ".github"
  assert_success
}

@test "check-all md" {
  run check-all "README.md"
  assert_failure
  run fix-all "README.md"
  run check-all "README.md"
  assert_success
}

@test "check-all bash/py" {
  run check-all "scripts"
  assert_failure
  run fix-all "scripts"
  run check-all "scripts"
  assert_success
}
