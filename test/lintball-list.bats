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
./a.md
./a.nim
./a.yml
./bash/a
./bash/a.bash
./package.json
./py th on/a
./py th on/a.py
./py th on/a.pyx
./ruby/a
./ruby/a.rb
./sh/a
./sh/a.sh
./test/a.bats
./test/a.expected
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
./a.md
./a.nim
./a.yml
./bash/a
./bash/a.bash
./package.json
./py th on/a
./py th on/a.py
./py th on/a.pyx
./ruby/a
./ruby/a.rb
./sh/a
./sh/a.sh
./test/a.bats
./test/a.expected
EOF
  )"
}
