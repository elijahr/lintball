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

@test "lintball --write yml" {
  run lintball --write "a.yml"
  assert_success
  expected="$(
    cat <<EOF
key: value
hello: world
EOF
  )"
  assert_equal "$(cat "a.yml")" "$expected"
}

@test "lintball --write md" {
  run lintball --write "a.md"
  assert_success
  expected="$(
    cat <<EOF
| aaaa | bbbbbb |  cc |
| :--- | :----: | --: |
| a    |   b    |   c |
EOF
  )"
  assert_equal "$(cat "a.md")" "$expected"
}

@test "lintball --write sh" {
  run lintball --write "sh/a.sh"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}
EOF
  )"
  assert_equal "$(cat "sh/a.sh")" "$expected"
}

@test "lintball --write sh (inferred from hashbang)" {
  run lintball --write "sh/a"
  assert_success
  expected="$(
    cat <<EOF
#!/bin/sh

a() {
  echo

}

b() {

  echo
}
EOF
  )"
  assert_equal "$(cat "sh/a")" "$expected"
}

@test "lintball --write bash" {
  run lintball --write "bash/a.bash"
  assert_success
  expected="$(
    cat <<EOF
a() {
  echo

}

b() {

  echo
}

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "bash/a.bash")" "$expected"
}

@test "lintball --write bash (inferred from hashbang)" {
  run lintball --write "bash/a"
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

c=("a" "b" "c")

for var in "\${c[@]}"; do
  echo "\$var"
done
EOF
  )"
  assert_equal "$(cat "bash/a")" "$expected"
}

@test "lintball --write bats" {
  run lintball --write "test"
  assert_success
  assert_equal "$(cat "test/c.bats")" "$(cat "test/c.expected")"
}

@test "lintball --write python" {
  run lintball --write "py th on/a.py"
  assert_success
  expected="$(
    cat <<EOF
"""A Python module.

This module docstring should be dedented.
"""

import path
import system


def a(arg):
    """This should be trimmed."""
    print(arg, "b", "c", "d")
    print(path)
    print(system)
EOF
  )"
  assert_equal "$(cat "py th on/a.py")" "$expected"
}

@test "lintball --write python (inferred from hashbang)" {
  run lintball --write "py th on/a"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env python3

"""A Python module.

This module docstring should be dedented.
"""

import path
import system


def a(arg):
    """This should be trimmed."""
    print(arg, "b", "c", "d")
    print(path)
    print(system)
EOF
  )"
  assert_equal "$(cat "py th on/a")" "$expected"
}

@test "lintball --write cython" {
  run lintball --write "py th on/a.pyx"
  assert_success
  expected="$(
    cat <<EOF

cdef void fun(char * a) nogil:
    cdef:
        char * dest = a
EOF
  )"
  assert_equal "$(cat "py th on/a.pyx")" "$expected"
}

@test "lintball --write nim" {
  run lintball --write "a.nim"
  assert_success
  expected="$(
    cat <<EOF

type
  A* = int
  B* = int

EOF
  )"
  assert_equal "$(cat "a.nim")" "$expected"
  assert_equal "$(cat "a.nim")" "$(echo "$expected")"
}

@test "lintball --write unhandled is a no-op" {
  run lintball --write "unhandled.txt"
  assert_success
}

@test "lintball --write does not fix ignored files" {
  prev="$(cat "py th on/a.py")"
  echo "# this is a comment" >".lintball-ignore"
  echo "*/py th on/*   # this is another comment" >>".lintball-ignore"
  run lintball --write "py th on/a.py"
  assert_success
  assert_equal "$(cat "py th on/a.py")" "$prev"
}

@test "lintball --write --list fails" {
  run lintball --write --list
  assert_failure
  run lintball --list --write
  assert_failure
}
