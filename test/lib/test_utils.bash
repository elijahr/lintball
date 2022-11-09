PROJECT_DIR="$(
  cd "$(dirname "$BATS_TEST_DIRNAME")"
  pwd
)"
export PROJECT_DIR

LINTBALL_DIR="$PROJECT_DIR"
export LINTBALL_DIR

PATH="${LINTBALL_DIR}/bin:$PATH"
export PATH

setup_test() {
  TEST_PROJECT_DIR="$(mktemp -d)/fixture"
  export TEST_PROJECT_DIR
  cp -r "${LINTBALL_DIR}/test/fixture/" "${TEST_PROJECT_DIR}/"
  cp "${LINTBALL_DIR}/.gitignore" "${TEST_PROJECT_DIR}/"
  echo "nim 1.6.8" >"${TEST_PROJECT_DIR}/.tool-versions"
  rustup override set nightly --path "$TEST_PROJECT_DIR"
  cd "$TEST_PROJECT_DIR"
  git config --global init.defaultBranch devel
  git init .
  git config --local user.name "Bats Test"
  git config --local user.email "test@example.org"
}

teardown_test() {
  rm -rf "$(dirname "$TEST_PROJECT_DIR")"
  unset TEST_PROJECT_DIR
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
