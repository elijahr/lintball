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

@test "lintball yml" {
  run lintball "a.yml"
  assert_failure
  run lintball --write "a.yml"
  run lintball "a.yml"
  assert_success
}

@test "lintball md" {
  run lintball "a.md"
  assert_failure
  run lintball --write "a.md"
  run lintball "a.md"
  assert_success
}

@test "lintball sh" {
  run lintball "sh/a.sh"
  assert_failure
  run lintball --write "sh/a.sh"
  run lintball "sh/a.sh"
  assert_success
}

@test "lintball sh (inferred from hashbang)" {
  run lintball "sh/a"
  assert_failure
  run lintball --write "sh/a"
  run lintball "sh/a"
  assert_success
}

@test "lintball bash" {
  run lintball "bash/a.bash"
  assert_failure
  run lintball --write "bash/a.bash"
  run lintball "bash/a.bash"
  assert_success
}

@test "lintball bash (inferred from hashbang)" {
  run lintball "bash/a"
  assert_failure
  run lintball --write "bash/a"
  run lintball "bash/a"
  assert_success
}

@test "lintball bats" {
  run lintball "test"
  assert_failure
  run lintball --write "test"
  run lintball "test"
  assert_success
}

@test "lintball python" {
  run lintball "py th on/a.py"
  assert_failure
  run lintball --write "py th on/a.py"
  run lintball "py th on/a.py"
  assert_success
}

@test "lintball python (inferred from hashbang)" {
  run lintball "py th on/a"
  assert_failure
  run lintball --write "py th on/a"
  run lintball "py th on/a"
  assert_success
}

@test "lintball nim" {
  run lintball "a.nim"
  assert_failure
  run lintball --write "a.nim"
  run lintball "a.nim"
  assert_success
}

@test "lintball unhandled is a no-op" {
  run lintball "unhandled.txt"
  assert_success
}

@test "lintball does not check ignored files" {
  prev="$(cat "py th on/a.py")"
  echo "# this is a comment" >".lintball-ignore"
  echo "*/py th on/*   # this is another comment" >>".lintball-ignore"
  run lintball "py th on/a.py"
  assert_success
}
