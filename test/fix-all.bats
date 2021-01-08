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

@test "fix-all yml" {
  run fix-all ".github"
  assert_success
  assert_equal "$(cat ".github/workflows/test.yml")" $'key: value\nhello: world'
}

@test "fix-all md" {
  run fix-all "README.md"
  assert_success
  expected="$(
    cat <<EOF
| aaaa | bbbbbb |  cc |
| :--- | :----: | --: |
| a    |   b    |   c |
EOF
  )"
  assert_equal "$(cat "README.md")" "$expected"
}

@test "fix-all bash" {
  run fix-all "scripts"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env bash

a() {
  echo

}

b() {
  echo
}
EOF
  )"
  assert_equal "$(cat "scripts/a")" "$expected"
  assert_equal "$(cat "scripts/a.bash")" "$(echo "$expected" | tail -n+3)"
}

@test "fix-all bats" {
  run fix-all "test"
  assert_success
  assert_equal "$(cat "test/c.bats")" "$(cat "test/c.expected")"
}

@test "fix-all py" {
  run fix-all "scripts"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env python3


def a():
    print("b", "c", "d")
EOF
  )"
  assert_equal "$(cat "scripts/b")" "$expected"
  assert_equal "$(cat "scripts/b.py")" "$(echo "$expected" | tail -n+4)"
}
