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

  cp -r "${LINTBALL_DIR}/test/fixture/" "${BATS_TEST_TMPDIR}/"
  cp "${LINTBALL_DIR}/.gitignore" "${BATS_TEST_TMPDIR}/"

  # rustup override set nightly --path "$BATS_TEST_TMPDIR"
  cd "${BATS_TEST_TMPDIR}"
  git config --global init.defaultBranch devel
  git init .
  git config --local user.name "Bats Test"
  git config --local user.email "test@example.org"
}

teardown_test() {
  unset LINTBALL_DIR
  PATH="${ORIGINAL_PATH}"
  export PATH
}
