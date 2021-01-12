export LINTBALL_DIR
LINTBALL_DIR="$(realpath "$(dirname "$BATS_TEST_DIRNAME")")"

export ORIGINAL_PATH
ORIGINAL_PATH="$PATH"

setup_test() {
  export PATH="${LINTBALL_DIR}/bin:$PATH"
  export PROJECT_DIR
  PROJECT_DIR="$(mktemp -d)/fixture"
  cp -r "${LINTBALL_DIR}/fixture/" "$PROJECT_DIR/"
  cp "${LINTBALL_DIR}/.gitignore" "$PROJECT_DIR/"
  cp "${LINTBALL_DIR}/.tool-versions" "$PROJECT_DIR/"

  cd "$PROJECT_DIR"
  rm -rf node_modules
  npm install --include=dev
}

teardown_test() {
  rm -rf "$(dirname "$PROJECT_DIR")"
  unset PROJECT_DIR
  export PATH="$ORIGINAL_PATH"
}
