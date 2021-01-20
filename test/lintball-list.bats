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

@test 'lintball list handles implicit path' {
  mkdir foo
  cd foo
  run lintball list
  assert_success
}

@test 'lintball list handles paths with spaces' {
  mkdir -p "aaa aaa/bbb bbb"
  cp "a.yml" "aaa aaa/bbb bbb/a b.yml"
  run lintball list "aaa aaa/bbb bbb/a b.yml"
  assert_success
  assert_line "./aaa aaa/bbb bbb/a b.yml"
}

@test 'lintball list ignores ignored files' {
  mkdir -p vendor
  cp a.rb vendor/
  run lintball list
  assert_success
  expected="$(
    cat <<EOF
./Cargo.toml
./a.bash
./a.bats
./a.bats.expected
./a.c
./a.cpp
./a.cs
./a.css
./a.d
./a.dash
./a.h
./a.hpp
./a.html
./a.java
./a.js
./a.json
./a.jsx
./a.ksh
./a.lua
./a.m
./a.md
./a.mksh
./a.nim
./a.pug
./a.py
./a.pyx
./a.rb
./a.scss
./a.sh
./a.ts
./a.tsx
./a.xml
./a.yml
./a_bash
./a_js
./a_py
./a_rb
./a_sh
./b_bash
./b_js
./package.json
./src/main.rs
EOF
  )"
  assert_output "$expected"
}

@test 'lintball list ignores ignored files whose path is explicitly passed as an arg' {
  mkdir -p vendor
  cp a.rb vendor/
  run lintball list "vendor/a.rb"
  assert_success
  expected="$(
    cat <<EOF
./Cargo.toml
./a.bash
./a.bats
./a.bats.expected
./a.c
./a.cpp
./a.cs
./a.css
./a.d
./a.dash
./a.h
./a.hpp
./a.html
./a.java
./a.js
./a.json
./a.jsx
./a.ksh
./a.lua
./a.m
./a.md
./a.mksh
./a.nim
./a.pug
./a.py
./a.pyx
./a.rb
./a.scss
./a.sh
./a.ts
./a.tsx
./a.xml
./a.yml
./a_bash
./a_js
./a_py
./a_rb
./a_sh
./b_bash
./b_js
./package.json
./src/main.rs
EOF
  )"
}
