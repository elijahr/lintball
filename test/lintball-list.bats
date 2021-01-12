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

@test "lintball ignores ignored files" {
  echo "# this is a comment" >".lintball-ignore"
  echo "*/py th on/*   # this is another comment" >>".lintball-ignore"
  echo "*/*.json" >>".lintball-ignore"
  echo "*/node_modules/*" >>".lintball-ignore"
  run lintball --list
  assert_success
  expected="$(
    cat <<EOF
./a.yml
./test/a.expected
./test/a.bats
./bash/a
./bash/a.bash
./a.nim
./sh/a
./sh/a.sh
./a.md
EOF
  )"
  assert_output "$expected"
}

@test "lintball ignores ignored files whose path is explicitly passed as and arg" {
  echo "# this is a comment" >".lintball-ignore"
  echo "*/py th on/*   # this is another comment" >>".lintball-ignore"
  echo "*/*.json" >>".lintball-ignore"
  echo "*/node_modules/*" >>".lintball-ignore"
  run lintball --list "py th on/a.py"
  assert_success
  expected="$(
    cat <<EOF
./a.yml
./test/a.expected
./test/a.bats
./bash/a
./bash/a.bash
./a.nim
./sh/a
./sh/a.sh
./a.md
EOF
  )"
}
