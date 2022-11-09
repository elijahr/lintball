#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ./lib/test_utils

setup_file() {
  clear_lock git
}

teardown_file() {
  clear_lock git
}

setup() {
  setup_test
  # optimization, only fix a few arbitrary files
  find . \
    -type f \
    -not \( -path "*/.git/*" \) \
    -not -name '.gitignore' \
    -not -name 'a.md' \
    -not -name 'a.txt' \
    -not -name 'a.yml' \
    -delete
  get_lock git
  git add .gitignore
  git commit -m "Initial commit"
  clear_lock git
}

teardown() {
  teardown_test
}

@test 'pre-commit adds fixed code to git index' {
  get_lock git
  git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
a.md
a.txt
a.yml
EOF
  )"
  # Everything is staged in index
  assert_equal "$(git diff --name-only --cached | sort)" "$expected"
  # Nothing is partially staged
  assert_equal "$(git diff --name-only)" ""
  clear_lock git
}

@test 'pre-commit does not interfere with delete-only commits' {
  get_lock git
  git add .
  git commit -m "commit 1"
  git rm a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  clear_lock git
  assert_success
  assert_output ""
  assert [ ! -f "a.md" ]
}

@test 'pre-commit does not fix ignored files' {
  mkdir -p vendor
  cp a.md vendor/
  get_lock git
  git add -f vendor/a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  clear_lock git
  assert_success
  assert_equal "$(cat "vendor/a.md")" "$(cat "a.md")"
}

@test 'pre-commit fixes code' {
  get_lock git
  git add a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  clear_lock git
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
  mv "a.yml" "aaa aaa/bbb bbb/a b.yml"
  get_lock git
  git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
a.md
a.txt
aaa aaa/bbb bbb/a b.yml
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
  clear_lock git
  assert_equal "$(cat "aaa aaa/bbb bbb/a b.yml")" "$expected"
}

# shellcheck disable=SC2016
@test 'pre-commit uses \${LINTBALL_DIR}/bin/lintball if it exists' {
  mkdir -p ./lintball-dir/bin
  echo '#!/bin/sh' >./lintball-dir/bin/lintball
  echo 'echo in ./lintball-dir/bin/lintball' >>./lintball-dir/bin/lintball
  chmod +x ./lintball-dir/bin/lintball
  LINTBALL_DIR="${PWD}/lintball-dir"
  export LINTBALL_DIR
  run "${PROJECT_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./lintball-dir/bin/lintball"
}

@test 'pre-commit uses ./bin/lintball if it exists' {
  unset LINTBALL_DIR
  mkdir -p ./bin
  echo '#!/bin/sh' >./bin/lintball
  echo 'echo in ./bin/lintball' >>./bin/lintball
  chmod +x ./bin/lintball
  run "${PROJECT_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./bin/lintball"
}

@test 'pre-commit uses ./node_modules/lintball/bin/lintball if it exists' {
  unset LINTBALL_DIR
  mkdir -p ./node_modules/lintball/bin
  echo '#!/bin/sh' >./node_modules/lintball/bin/lintball
  echo 'echo in ./node_modules/lintball/bin/lintball' >>./node_modules/lintball/bin/lintball
  chmod +x ./node_modules/lintball/bin/lintball
  run "${PROJECT_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./node_modules/lintball/bin/lintball"
}

@test 'pre-commit uses global lintball if it exists' {
  unset LINTBALL_DIR
  mkdir -p ./other
  echo '#!/bin/sh' >./other/lintball
  echo 'echo in ./other/lintball' >>./other/lintball
  chmod +x ./other/lintball
  PATH="${PWD}/other:${ORIGINAL_PATH}"
  export PATH
  assert_equal "$(command -v lintball)" "${PWD}/other/lintball"
  run "${PROJECT_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./other/lintball"
}
