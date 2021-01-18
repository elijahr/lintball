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

@test "lintball fix yml" {
  run lintball fix "a.yml"
  assert_success
  expected="$(
    cat <<EOF
key: value
hello: world
EOF
  )"
  assert_equal "$(cat "a.yml")" "$expected"
}

@test "lintball fix md" {
  run lintball fix "a.md"
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

@test "lintball fix sh" {
  run lintball fix "sh/a.sh"
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

@test "lintball fix sh (inferred from shebang)" {
  run lintball fix "sh/a"
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

@test "lintball fix bash" {
  run lintball fix "bash/a.bash"
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

@test "lintball fix bash (inferred from shebang)" {
  run lintball fix "bash/a"
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

@test "lintball fix bash (inferred from lintball directive)" {
  run lintball fix "bash/b"
  assert_success
  directive="# lintball lang=bash"
  expected="$(
    cat <<EOF
$directive

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
  assert_equal "$(cat "bash/b")" "$expected"
}

@test "lintball fix bats" {
  run lintball fix "test"
  assert_success
  assert_equal "$(cat "test/c.bats")" "$(cat "test/c.expected")"
}

@test "lintball fix javascript" {
  run lintball fix "javascript/a.js"
  assert_success
  expected="$(
    cat <<EOF
modules.exports = {
  foo: function () {},
  bar: () => ({}),
};
EOF
  )"
  assert_equal "$(cat "javascript/a.js")" "$expected"
}

@test "lintball fix javascript (inferred from node shebang)" {
  run lintball fix "javascript/a"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env node

modules.exports = {
  foo: function () {},
  bar: () => ({}),
};
EOF
  )"
  assert_equal "$(cat "javascript/a")" "$expected"
}

@test "lintball fix javascript (inferred from deno shebang)" {
  run lintball fix "javascript/b"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env deno

modules.exports = {
  foo: function () {},
  bar: () => ({}),
};
EOF
  )"
  assert_equal "$(cat "javascript/b")" "$expected"
}

@test "lintball fix python" {
  run lintball fix "py th on/a.py"
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

@test "lintball fix python (inferred from shebang)" {
  run lintball fix "py th on/a"
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

@test "lintball fix cython" {
  run lintball fix "py th on/a.pyx"
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

@test "lintball fix nim" {
  run lintball fix "a.nim"
  assert_success
  expected="$(
    cat <<EOF

type
  A* = int
  B* = int

EOF
  )"
  assert_equal "$(cat "a.nim")" "$expected"
}

@test "lintball fix ruby" {
  run lintball fix "ruby/a.rb"
  assert_success
  expected="$(
    cat <<EOF
# frozen_string_literal: true

d = [123, 456,
     789]

echo d
EOF
  )"
  assert_equal "$(cat "ruby/a.rb")" "$expected"
}

@test "lintball fix ruby (inferred from shebang)" {
  run lintball fix "ruby/a"
  assert_success
  expected="$(
    cat <<EOF
#!/usr/bin/env ruby
# frozen_string_literal: true

d = [123, 456,
     789]

echo d
EOF
  )"
  assert_equal "$(cat "ruby/a")" "$expected"
}

@test "lintball fix unhandled is a no-op" {
  run lintball fix "unhandled.txt"
  assert_success
}

@test "lintball fix does not fix ignored files" {
  mkdir -p vendor
  cp ruby/a.rb vendor/
  run lintball fix vendor/a.rb
  assert_success
  assert_equal "$(cat "vendor/a.rb")" "$(cat "ruby/a.rb")"
}
