# shellcheck disable=2164

setup_test() {
  PROJECT_DIR="$(
    cd "$(dirname "${BATS_TEST_DIRNAME}")" || exit 1
    pwd
  )"
  export PROJECT_DIR

  LINTBALL_DIR="${PROJECT_DIR}"
  export LINTBALL_DIR

  ORIGINAL_PATH="${ORIGINAL_PATH:-${PATH}}"
  export ORIGINAL_PATH

  PATH="${LINTBALL_DIR}/bin:${PATH}"
  export PATH

  TEST_PROJECT_DIR="$(mktemp -d)/fixture"
  export TEST_PROJECT_DIR

  cp -r "${LINTBALL_DIR}/test/fixture/" "${TEST_PROJECT_DIR}/"
  cp "${LINTBALL_DIR}/.gitignore" "${TEST_PROJECT_DIR}/"

  # rustup override set nightly --path "$TEST_PROJECT_DIR"
  cd "${TEST_PROJECT_DIR}"
  git config --global init.defaultBranch devel
  git init .
  git config --local user.name "Bats Test"
  git config --local user.email "test@example.org"
}

teardown_test() {
  rm -rf "$(dirname "${TEST_PROJECT_DIR}")"
  unset TEST_PROJECT_DIR
  unset LINTBALL_DIR
  PATH="${ORIGINAL_PATH}"
  export PATH
}
