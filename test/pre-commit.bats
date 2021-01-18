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
package-lock.json
package.json
py th on/a
py th on/a.py
py th on/a.pyx
ruby/a
ruby/a.rb
sh/a
sh/a.sh
test/a.bats
test/a.expected
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
