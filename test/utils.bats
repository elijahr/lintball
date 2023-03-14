load ../tools/node_modules/bats-support/load
load ../tools/node_modules/bats-assert/load
load ../lib/utils.bash
load ./lib/test_utils.bash

setup() {
  LINTBALL_DIR="$(
    cd "$(dirname "${BATS_TEST_DIRNAME}")" || exit 1
    pwd
  )"
  export LINTBALL_DIR

  ORIGINAL_PATH="${ORIGINAL_PATH:-${PATH}}"
  export ORIGINAL_PATH

  PATH="${LINTBALL_DIR}/bin:${PATH}"
  export PATH
  DIR="$(mktemp -d)"
  export DIR
  cd "${DIR}" || return $?
}

teardown() {
  rm -rf "${DIR}"
  PATH="${ORIGINAL_PATH}"
  export PATH
}

@test "generate_find_cmd" {
  # shellcheck disable=SC2034
  declare -a LINTBALL_HANDLED_EXTENSIONS=('c' 'M' 'py' 'tsx')
  run generate_find_cmd
  assert_success
  assert_output "'find' '-L' '.' '-type' 'f' '-a' '(' '(' '-name' '*.c' '-o' '-name' '*.M' '-o' '-name' '*.py' '-o' '-name' '*.tsx' ')' '-o' '(' '-not' '(' '-name' '*.*' ')' ')' ')' '-print'"

  run generate_find_cmd " "
  assert_success
  assert_output "'find' '-L' '.' '-type' 'f' '-a' '(' '(' '-name' '*.c' '-o' '-name' '*.M' '-o' '-name' '*.py' '-o' '-name' '*.tsx' ')' '-o' '(' '-not' '(' '-name' '*.*' ')' ')' ')' '-print'"

  run generate_find_cmd " " " " " "
  assert_success
  assert_output "'find' '-L' '.' '-type' 'f' '-a' '(' '(' '-name' '*.c' '-o' '-name' '*.M' '-o' '-name' '*.py' '-o' '-name' '*.tsx' ')' '-o' '(' '-not' '(' '-name' '*.*' ')' ')' ')' '-print'"

  run generate_find_cmd "aaa bbb/ccc ddd/eee/ fff"
  assert_success
  assert_output "'find' '-L' './aaa bbb/ccc ddd/eee/ fff' '-type' 'f' '-a' '(' '(' '-name' '*.c' '-o' '-name' '*.M' '-o' '-name' '*.py' '-o' '-name' '*.tsx' ')' '-o' '(' '-not' '(' '-name' '*.*' ')' ')' ')' '-print'"

  declare -a LINTBALL_IGNORE_GLOBS=('*.py' '*.rb')
  run generate_find_cmd "dir1" "dir2"
  assert_success
  assert_output "'find' '-L' './dir1' './dir2' '-type' 'f' '-a' '(' '-not' '-path' '*.py' ')' '-a' '(' '-not' '-path' '*.rb' ')' '-a' '(' '(' '-name' '*.c' '-o' '-name' '*.M' '-o' '-name' '*.py' '-o' '-name' '*.tsx' ')' '-o' '(' '-not' '(' '-name' '*.*' ')' ')' ')' '-print'"
  # shellcheck disable=SC2034
  LINTBALL_IGNORE_GLOBS=()

  run generate_find_cmd " dir1" "dir2 "
  assert_success
  assert_output "'find' '-L' './dir1' './dir2' '-type' 'f' '-a' '(' '(' '-name' '*.c' '-o' '-name' '*.M' '-o' '-name' '*.py' '-o' '-name' '*.tsx' ')' '-o' '(' '-not' '(' '-name' '*.*' ')' ')' ')' '-print'"
  # shellcheck disable=SC2034
  LINTBALL_HANDLED_EXTENSIONS=()
}

@test "config_find" {
  mkdir subdir
  touch subdir/.lintballrc.json
  cd subdir
  run lintball exec config_find 3>&-
  assert_success
  assert_output "${DIR}/subdir/.lintballrc.json"

  # find in parent dir
  mv .lintballrc.json ../.lintballrc.json
  run lintball exec config_find 3>&-
  assert_success
  assert_output "${DIR}/.lintballrc.json"

  # find symlink
  ln -s "${DIR}/.lintballrc.json" .lintballrc.json
  run lintball exec config_find 3>&-
  assert_success
  assert_output "${DIR}/subdir/.lintballrc.json"
  rm .lintballrc.json

  run lintball exec config_find "path=." 3>&-
  assert_success
  assert_output "${DIR}/.lintballrc.json"

  run lintball exec config_find "path=" 3>&-
  assert_failure
  assert_output "Not a valid path arg: "

  cd /tmp
  run lintball exec config_find "path=${DIR}" 3>&-
  assert_success
  assert_output "${DIR}/.lintballrc.json"

  run lintball exec config_find "path=${DIR}/subdir" 3>&-
  assert_success
  assert_output "${DIR}/.lintballrc.json"

  run lintball exec config_find "path=${DIR}/subdir2" 3>&-
  assert_failure
  assert_output "Not a valid path arg: ${DIR}/subdir2"

  ln -s "${DIR}/subdir" "${DIR}/subdir2"
  run lintball exec config_find "path=${DIR}/subdir2" 3>&-
  assert_success
  assert_output "${DIR}/.lintballrc.json"

  cd "${DIR}" || return $?
  rm .lintballrc.json
  run lintball exec config_find 3>&-
  assert_failure
  assert_output ""
}

@test "config_load" {
  # required arg
  run lintball exec config_load 3>&-
  assert_failure

  # no path
  run lintball exec config_load "path=${DIR}/.lintballrc.json" 3>&-
  assert_failure

  # invalid path
  run lintball exec config_load "path=.lintballrc.json" 3>&-
  assert_failure

  # valid path
  cp "${LINTBALL_DIR}/configs/lintballrc-defaults.json" "${DIR}/.lintballrc.json"
  run lintball exec config_load "path=${DIR}/.lintballrc.json" 3>&-
  assert_success

  rm "${DIR}/.lintballrc.json"

  # valid path
  cp "${LINTBALL_DIR}/configs/lintballrc-defaults.json" ".lintballrc.json"
  run lintball exec config_load "path=.lintballrc.json" 3>&-
  assert_success

  run lintball exec config_load "path=./.lintballrc.json" 3>&-
  assert_success

  mkdir subdir
  run lintball exec config_load "path=subdir/../.lintballrc.json" 3>&-
  assert_success

  run lintball exec config_load "path=$(pwd)/subdir/../.lintballrc.json" 3>&-
  assert_success

  cd subdir
  run lintball exec config_load "path=../.lintballrc.json" 3>&-
  assert_success
}

@test "parse_major_version" {
  version="1.2.3"
  major_version=$(parse_major_version "${version}")
  assert_equal "${major_version}" "1"
}
