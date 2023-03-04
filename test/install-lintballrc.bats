#!/usr/bin/env bats

load ../tools/node_modules/bats-support/load
load ../tools/node_modules/bats-assert/load
load ./lib/test_utils

setup() {
  setup_test
}

teardown() {
  teardown_test
}

@test 'lintball install-lintballrc copies lintballrc-ignores.json → .lintballrc.json' {
  assert [ ! -f ".lintballrc.json" ]
  run lintball install-lintballrc --no
  assert_success
  assert [ -f ".lintballrc.json" ]
  assert_equal "$(cat .lintballrc.json)" "$(cat "${LINTBALL_DIR}/configs/lintballrc-ignores.json")"
}

@test 'lintball install-lintballrc does not overwrite existing .lintballrc.json' {
  echo "{}" >".lintballrc.json"
  run lintball install-lintballrc --no
  assert_failure
  assert [ -f ".lintballrc.json" ]
  assert_equal "$(cat .lintballrc.json)" "{}"
}
