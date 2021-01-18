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
  cp -r "${LINTBALL_DIR}/fixture/" "${TEST_PROJECT_DIR}/"
  cp "${LINTBALL_DIR}/.gitignore" "${TEST_PROJECT_DIR}/"
  echo "nim 1.4.2" >"${TEST_PROJECT_DIR}/.tool-versions"

  cd "$TEST_PROJECT_DIR" || exit
  rm -rf node_modules
  npm install --include=dev
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
