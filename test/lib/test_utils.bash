LINTBALL_DIR="$(realpath "$(dirname "$BATS_TEST_DIRNAME")")"
export LINTBALL_DIR

ORIGINAL_PATH="$PATH"
export ORIGINAL_PATH

setup_test() {
  PATH="${LINTBALL_DIR}/bin:$PATH"
  export PATH
  PROJECT_DIR="$(mktemp -d)/fixture"
  export PROJECT_DIR
  cp -r "${LINTBALL_DIR}/fixture/" "$PROJECT_DIR/"
  cp "${LINTBALL_DIR}/.gitignore" "$PROJECT_DIR/"
  cp "${LINTBALL_DIR}/.tool-versions" "$PROJECT_DIR/"

  cd "$PROJECT_DIR" || exit
  rm -rf node_modules
  npm install --include=dev
}

teardown_test() {
  rm -rf "$(dirname "$PROJECT_DIR")"
  unset PROJECT_DIR
  export PATH="$ORIGINAL_PATH"
}

git_branch() {
  (
    cd "$LINTBALL_REPO"
    git rev-parse --abbrev-ref HEAD
  )
}
