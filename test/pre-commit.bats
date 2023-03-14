#!/usr/bin/env bats

load ../tools/node_modules/bats-support/load
load ../tools/node_modules/bats-assert/load
load ./lib/test_utils

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
    -not -name '.lintballrc.json' \
    -delete
  safe_git add .gitignore
  safe_git commit -m "Initial commit"
}

teardown() {
  teardown_test
}

@test 'pre-commit adds fixed code to git index' {
  safe_git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
.lintballrc.json
a.md
a.txt
a.yml
EOF
  )"
  # Everything is staged in index
  assert_equal "$(safe_git diff --name-only --cached | sort)" "${expected}"
  # Nothing is partially staged
  assert_equal "$(safe_git diff --name-only)" ""
}

@test 'pre-commit does not interfere with delete-only commits' {
  safe_git add .
  safe_git commit -m "commit 1"
  safe_git rm a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_line "No fully staged files, nothing to do."
  assert [ ! -f "a.md" ]
}

@test 'pre-commit does not fix ignored files' {
  mkdir -p a_dir
  cp a.md a_dir/
  safe_git add a.md a_dir
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
| aaaa | bbbbbb |  cc |
| :--- | :----: | --: |
| a    |   b    |   c |
EOF
  )"
  assert_equal "$(cat "a.md")" "${expected}"
  assert_not_equal "$(cat a_dir/a.md)" "${expected}"
}

@test 'pre-commit fixes code' {
  safe_git add a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
| aaaa | bbbbbb |  cc |
| :--- | :----: | --: |
| a    |   b    |   c |
EOF
  )"
  assert_equal "$(cat "a.md")" "${expected}"
}

@test 'pre-commit handles paths with spaces' {
  mkdir -p "aaa aaa/bbb bbb"
  mv "a.yml" "aaa aaa/bbb bbb/a b.yml"
  safe_git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  expected="$(
    cat <<EOF
.lintballrc.json
a.md
a.txt
aaa aaa/bbb bbb/a b.yml
EOF
  )"
  # Everything is staged in index
  assert_equal "$(safe_git diff --name-only --cached | sort)" "${expected}"
  # Nothing is partially staged
  assert_equal "$(safe_git diff --name-only)" ""
  # file was actually fixed
  expected="$(
    cat <<EOF
key: value
hello: world
EOF
  )"
  assert_equal "$(cat "aaa aaa/bbb bbb/a b.yml")" "${expected}"
}

# shellcheck disable=SC2016
@test 'pre-commit uses \${LINTBALL_DIR}/bin/lintball if it exists' {
  mkdir -p ./lintball-dir/bin
  echo '#!/bin/sh' >./lintball-dir/bin/lintball
  echo 'echo in ./lintball-dir/bin/lintball' >>./lintball-dir/bin/lintball
  chmod +x ./lintball-dir/bin/lintball
  # shellcheck disable=SC2097,SC2098
  LINTBALL_DIR="${PWD}/lintball-dir" run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./lintball-dir/bin/lintball"
}

@test 'pre-commit uses ./bin/lintball if it exists' {
  mkdir -p ./bin
  echo '#!/bin/sh' >./bin/lintball
  echo 'echo in ./bin/lintball' >>./bin/lintball
  chmod +x ./bin/lintball
  # shellcheck disable=SC2097,SC2098
  LINTBALL_DIR="" run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./bin/lintball"
}

@test 'pre-commit uses ./node_modules/lintball/bin/lintball if it exists' {
  mkdir -p ./node_modules/lintball/bin
  echo '#!/bin/sh' >./node_modules/lintball/bin/lintball
  echo 'echo in ./node_modules/lintball/bin/lintball' >>./node_modules/lintball/bin/lintball
  chmod +x ./node_modules/lintball/bin/lintball
  # shellcheck disable=SC2097,SC2098
  LINTBALL_DIR="" run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_output "in ./node_modules/lintball/bin/lintball"
}

@test 'pre-commit uses global lintball if it exists' {
  mkdir -p ./other
  echo '#!/bin/sh' >./other/lintball
  echo 'echo in ./other/lintball' >>./other/lintball
  chmod +x ./other/lintball
  # shellcheck disable=SC2097,SC2098
  LINTBALL_DIR="" PATH="${PWD}/other:${ORIGINAL_PATH}" run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_line "in ./other/lintball"
}
