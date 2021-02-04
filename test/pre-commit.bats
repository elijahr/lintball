#!/usr/bin/env bats

load ../node_modules/bats-support/load
load ../node_modules/bats-assert/load
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
    -delete
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
a.md
a.txt
a.yml
EOF
  )"
  # Everything is staged in index
  assert_equal "$(git diff --name-only --cached | sort)" "$expected"
  # Nothing is partially staged
  assert_equal "$(git diff --name-only)" ""
}

@test 'pre-commit does not interfere with delete-only commits' {
  git add .
  git commit -m "commit 1"
  git rm a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_output ""
  assert [ ! -f "a.md" ]
}

@test 'pre-commit does not fix ignored files' {
  mkdir -p vendor
  cp a.md vendor/
  git add -f vendor/a.md
  run "${LINTBALL_DIR}/githooks/pre-commit"
  assert_success
  assert_equal "$(cat "vendor/a.md")" "$(cat "a.md")"
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
  mv "a.yml" "aaa aaa/bbb bbb/a b.yml"
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
  assert_equal "$(cat "aaa aaa/bbb bbb/a b.yml")" "$expected"
}
