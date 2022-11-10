PROJECT_DIR="$(
  cd "$(dirname "$BATS_TEST_DIRNAME")"
  pwd
)"
export PROJECT_DIR

ORIGINAL_PATH="$PATH"
export ORIGINAL_PATH

get_lock() {
  local lock_path
  mkdir -p "${PROJECT_DIR}/.tmp"
  lock_path="${PROJECT_DIR}/.tmp/${1}.lock"
  # shellcheck disable=SC2188
  while ! {
    set -C
    2>/dev/null >"$lock_path"
  }; do
    sleep 0.01
  done
}

clear_lock() {
  local lock_path
  mkdir -p "${PROJECT_DIR}/.tmp"
  lock_path="${PROJECT_DIR}/.tmp/${1}.lock"
  rm -f "$lock_path"
}

setup_test() {
  LINTBALL_DIR="$PROJECT_DIR"
  export LINTBALL_DIR
  PATH="${LINTBALL_DIR}/bin:$PATH"
  export PATH

  TEST_PROJECT_DIR="$(mktemp -d)/fixture"
  export TEST_PROJECT_DIR
  cp -r "${LINTBALL_DIR}/test/fixture/" "${TEST_PROJECT_DIR}/"
  cp "${LINTBALL_DIR}/.gitignore" "${TEST_PROJECT_DIR}/"
  rustup override set nightly --path "$TEST_PROJECT_DIR"
  cd "$TEST_PROJECT_DIR"
  asdf local nim ref:version-1-6
  get_lock git
  git config --global init.defaultBranch devel
  git init .
  git config --local user.name "Bats Test"
  git config --local user.email "test@example.org"
  clear_lock git
}

teardown_test() {
  rm -rf "$(dirname "$TEST_PROJECT_DIR")"
  unset TEST_PROJECT_DIR
  unset LINTBALL_DIR
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
