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

@test "lintball check yml" {
  run lintball check "a.yml"
  assert_failure
  run lintball fix "a.yml"
  run lintball check "a.yml"
  assert_success
}

@test "lintball check md" {
  run lintball check "a.md"
  assert_failure
  run lintball fix "a.md"
  run lintball check "a.md"
  assert_success
}

@test "lintball check sh" {
  run lintball check "sh/a.sh"
  assert_failure
  run lintball fix "sh/a.sh"
  run lintball check "sh/a.sh"
  assert_success
}

@test "lintball check sh (inferred from hashbang)" {
  run lintball check "sh/a"
  assert_failure
  run lintball fix "sh/a"
  run lintball check "sh/a"
  assert_success
}

@test "lintball check bash" {
  run lintball check "bash/a.bash"
  assert_failure
  run lintball fix "bash/a.bash"
  run lintball check "bash/a.bash"
  assert_success
}

@test "lintball check bash (inferred from hashbang)" {
  run lintball check "bash/a"
  assert_failure
  run lintball fix "bash/a"
  run lintball check "bash/a"
  assert_success
}

@test "lintball check bats" {
  run lintball check "test"
  assert_failure
  run lintball fix "test"
  run lintball check "test"
  assert_success
}

@test "lintball check python" {
  run lintball check "py th on/a.py"
  assert_failure
  run lintball fix "py th on/a.py"
  run lintball check "py th on/a.py"
  assert_success
}

@test "lintball check python (inferred from hashbang)" {
  run lintball check "py th on/a"
  assert_failure
  run lintball fix "py th on/a"
  run lintball check "py th on/a"
  assert_success
}

@test "lintball check cython" {
  run lintball check "py th on/a.pyx"
  assert_failure
  run lintball fix "py th on/a.pyx"
  run lintball check "py th on/a.pyx"
  assert_success
}

@test "lintball check nim" {
  run lintball check "a.nim"
  assert_failure
  run lintball fix "a.nim"
  run lintball check "a.nim"
  assert_success
}

@test "lintball check ruby" {
  run lintball check "ruby/a.rb"
  assert_failure
  run lintball fix "ruby/a.rb"
  run lintball check "ruby/a.rb"
  assert_success
}

@test "lintball check ruby (inferred from hashbang)" {
  run lintball check "ruby/a"
  assert_failure
  run lintball fix "ruby/a"
  run lintball check "ruby/a"
  assert_success
}

@test "lintball check unhandled is a no-op" {
  run lintball check "unhandled.txt"
  assert_success
}

@test "lintball check does not check ignored files" {
  mkdir -p vendor
  cp ruby/a.rb vendor/
  run lintball check vendor/a.rb
  assert_success
}
