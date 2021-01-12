#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
load ../lib/utils
load ./lib/test_utils

setup() {
  setup_test
  git init .
  git config --local user.name "Bats Test"
  git config --local user.email "test@example.org"
  git add .gitignore .tool-versions
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
package-lock.json
package.json
py th on/a
py th on/a.py
sh/a
sh/a.sh
test/a.bats
test/a.expected
unhandled.txt
EOF
  )"
  # Everything is staged in index
  assert_equal "$(git diff --name-only --cached)" "$expected"
  # Nothing is partially staged
  assert_equal "$(git diff --name-only)" ""
}

@test "pre-commit does not fix ignored files" {
  prev="$(cat "py th on/a.py")"
  echo "# this is a comment" >".lintball-ignore"
  echo "*/py th on/*   # this is another comment" >>".lintball-ignore"
  git add .
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_equal "$(cat "py th on/a.py")" "$prev"
}
