#!/usr/bin/env bats

load ../deps/node_modules/bats-support/load
load ../deps/node_modules/bats-assert/load
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
./bash/b
./bats/a.bats
./bats/a.expected
./javascript/a
./javascript/a.js
./javascript/b
./py th on/a
./py th on/a.py
./py th on/a.pyx
./ruby/a
./ruby/a.rb
./sh/a
./sh/a.sh
./uncrustify/a.c
./uncrustify/a.cpp
./uncrustify/a.cs
./uncrustify/a.h
./uncrustify/a.hpp
./uncrustify/a.java
./uncrustify/a.m
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
./bash/b
./bats/a.bats
./bats/a.expected
./javascript/a
./javascript/a.js
./javascript/b
./py th on/a
./py th on/a.py
./py th on/a.pyx
./ruby/a
./ruby/a.rb
./sh/a
./sh/a.sh
./uncrustify/a.c
./uncrustify/a.cpp
./uncrustify/a.cs
./uncrustify/a.h
./uncrustify/a.hpp
./uncrustify/a.java
./uncrustify/a.m
EOF
  )"
}
