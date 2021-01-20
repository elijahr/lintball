PROJECT_DIR="$(realpath "$(dirname "$BATS_TEST_DIRNAME")")"
export PROJECT_DIR

LINTBALL_DIR="$PROJECT_DIR"
export LINTBALL_DIR

ORIGINAL_PATH="$PATH"
export ORIGINAL_PATH

setup_test() {
  PATH="${LINTBALL_DIR}/bin:$PATH"
  export PATH
  TEST_PROJECT_DIR="$(mktemp -d)/fixture"
  export TEST_PROJECT_DIR
  cp -r "${LINTBALL_DIR}/test/fixture/" "${TEST_PROJECT_DIR}/"
  cp "${LINTBALL_DIR}/.gitignore" "${TEST_PROJECT_DIR}/"
  echo "nim 1.4.2" >"${TEST_PROJECT_DIR}/.tool-versions"
  rustup override set nightly --path "$TEST_PROJECT_DIR"
  cd "$TEST_PROJECT_DIR"
}

teardown_test() {
  rm -rf "$(dirname "$TEST_PROJECT_DIR")"
  unset TEST_PROJECT_DIR
  PATH="$ORIGINAL_PATH"
  export PATH
}

git_branch() {
  (
    cd "$LINTBALL_REPO"
    git rev-parse --abbrev-ref HEAD
  )
}

git_sha() {
  (
    cd "$LINTBALL_REPO"
    git rev-parse HEAD
  )
}
