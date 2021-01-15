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

@test "lintball list ignores ignored files" {
  mkdir -p vendor
  cp ruby/a.rb vendor/
  run lintball list
  assert_success
  expected="$(
    cat <<EOF
./a.yml
./test/a.expected
./test/a.bats
./py th on/a.py
./py th on/a
./py th on/a.pyx
./bash/a
./bash/a.bash
./a.nim
./sh/a
./sh/a.sh
./package.json
./a.md
./ruby/a
./ruby/a.rb
EOF
  )"
  assert_output "$expected"
}

@test "lintball list ignores ignored files whose path is explicitly passed as an arg" {
  mkdir -p vendor
  cp ruby/a.rb vendor/
  run lintball list "vendor/a.rb"
  assert_success
  expected="$(
    cat <<EOF
./a.yml
./test/a.expected
./test/a.bats
./py th on/a.py
./py th on/a
./py th on/a.pyx
./bash/a
./bash/a.bash
./a.nim
./sh/a
./sh/a.sh
./package.json
./a.md
./ruby/a
./ruby/a.rb
EOF
  )"
}
