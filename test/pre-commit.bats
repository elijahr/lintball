#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
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

@test 'pre-commit adds fixed code to git index' {
  git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
Cargo.lock
Cargo.toml
a.bash
a.bats
a.bats.expected
a.c
a.cpp
a.cs
a.css
a.d
a.dash
a.h
a.hpp
a.html
a.java
a.js
a.json
a.jsx
a.ksh
a.lua
a.m
a.md
a.mksh
a.nim
a.pug
a.py
a.pyx
a.rb
a.scss
a.sh
a.ts
a.tsx
a.txt
a.xml
a.yml
a_bash
a_js
a_py
a_rb
a_sh
b_bash
b_js
package.json
src/main.rs
EOF
  )"
  # Everything is staged in index
  assert_equal "$(git diff --name-only --cached | sort)" "$expected"
  # Nothing is partially staged
  assert_equal "$(git diff --name-only)" ""
}

@test 'pre-commit does not fix ignored files' {
  mkdir -p vendor
  cp a.rb vendor/
  git add -f vendor/a.rb
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_equal "$(cat "vendor/a.rb")" "$(cat "a.rb")"
}

@test 'pre-commit fixes code' {
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

@test 'pre-commit handles paths with spaces' {
  mkdir -p "aaa aaa/bbb bbb"
  cp "a.yml" "aaa aaa/bbb bbb/a b.yml"
  git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
Cargo.lock
Cargo.toml
a.bash
a.bats
a.bats.expected
a.c
a.cpp
a.cs
a.css
a.d
a.dash
a.h
a.hpp
a.html
a.java
a.js
a.json
a.jsx
a.ksh
a.lua
a.m
a.md
a.mksh
a.nim
a.pug
a.py
a.pyx
a.rb
a.scss
a.sh
a.ts
a.tsx
a.txt
a.xml
a.yml
a_bash
a_js
a_py
a_rb
a_sh
aaa aaa/bbb bbb/a b.yml
b_bash
b_js
package.json
src/main.rs
EOF
  )"
  # Everything is staged in index
  assert_equal "$(git diff --name-only --cached | sort)" "$expected"
  # Nothing is partially staged
  assert_equal "$(git diff --name-only)" ""
  # file was actually fixed
  expected="$(
    cat <<EOF
key: value
hello: world
EOF
  )"
  assert_equal "$(cat "aaa aaa/bbb bbb/a b.yml")" "$expected"
}
