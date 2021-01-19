#!/usr/bin/env bats

load ../deps/node_modules/bats-support/load
load ../deps/node_modules/bats-assert/load
load ../lib/utils
load ./lib/test_utils

setup() {
  setup_test
  git init .
  git config --local user.name "Bats Test"
  git config --local user.email "test@example.org"
  git add .gitignore
  git commit -m "Initial commit"
}

teardown() {
  teardown_test
}

@test "pre-commit fixes code" {
  git add a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
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

@test "pre-commit adds fixed code to git index" {
  git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
a.md
a.nim
a.yml
bash/a
bash/a.bash
bash/b
bats/a.bats
bats/a.expected
javascript/a
javascript/a.js
javascript/b
py th on/a
py th on/a.py
py th on/a.pyx
ruby/a
ruby/a.rb
sh/a
sh/a.sh
uncrustify/a.c
uncrustify/a.cpp
uncrustify/a.cs
uncrustify/a.h
uncrustify/a.hpp
uncrustify/a.java
uncrustify/a.m
unhandled.txt
EOF
  )"
  # Everything is staged in index
  assert_equal "$(git diff --name-only --cached | sort)" "$expected"
  # Nothing is partially staged
  assert_equal "$(git diff --name-only)" ""
}

@test "pre-commit does not fix ignored files" {
  mkdir -p vendor
  cp ruby/a.rb vendor/
  git add -f vendor/a.rb
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_equal "$(cat "vendor/a.rb")" "$(cat "ruby/a.rb")"
}
