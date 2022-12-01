cmd_autoflake() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"
  if [ "$mode" = "write" ]; then
    echo "autoflake \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOFLAKE}") \
      '$path'"
  else
    echo "autoflake \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOFLAKE}") \
      '$path'"
  fi
}

cmd_autopep8() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"
  if [ "$mode" = "write" ]; then
    echo "autopep8 \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOPEP8}") \
      '$path'"
  else
    echo "autopep8 \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOPEP8}") \
      '$path'"
  fi
}

cmd_black() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"
  if [ "$mode" = "write" ]; then
    echo "black \
      $(eval echo "${LINTBALL__WRITE_ARGS__BLACK}") \
      '$path'"
  else
    echo "black \
      $(eval echo "${LINTBALL__CHECK_ARGS__BLACK}") \
      '$path'"
  fi
}

cmd_clippy() {
  local mode path dir
  mode="${1#mode=}"
  path="${2#path=}"
  # path is Cargo.toml, so cd to containing directory to run clippy
  dir="$(dirname "$path")"
  if [ "$mode" = "write" ]; then
    echo "(cd '$dir'; cargo +nightly clippy \
      $(eval echo "${LINTBALL__WRITE_ARGS__CLIPPY}"))"
  else
    echo "(cd '$dir'; cargo +nightly clippy \
      $(eval echo "${LINTBALL__CHECK_ARGS__CLIPPY}"))"
  fi
}

cmd_docformatter() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"
  if [ "$mode" = "write" ]; then
    echo "docformatter \
      $(eval echo "${LINTBALL__WRITE_ARGS__DOCFORMATTER}") \
      '$path'"
  else
    echo "docformatter \
      $(eval echo "${LINTBALL__CHECK_ARGS__DOCFORMATTER}") \
      '$path'"
  fi
}

cmd_isort() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"
  if [ "$mode" = "write" ]; then
    echo "isort \
      $(eval echo "${LINTBALL__WRITE_ARGS__ISORT}") \
      '$path'"
  else
    echo "isort \
      $(eval echo "${LINTBALL__CHECK_ARGS__ISORT}") \
      '$path'"
  fi
}

cmd_prettier() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"
  if [ "$mode" = "write" ]; then
    echo "prettier \
      $(eval echo "${LINTBALL__WRITE_ARGS__PRETTIER}") \
      '$path'"
  else
    echo "prettier \
      --check \
      $(eval echo "${LINTBALL__CHECK_ARGS__PRETTIER}") \
      '$path'"
  fi
}

cmd_pylint() {
  local mode path format
  mode="${1#mode=}"
  path="${2#path=}"

  # show colors in output only if interactive shell
  format="text"
  if [[ $- == *i* ]]; then
    format="colorized"
  fi
  if [ "$mode" = "write" ]; then
    echo "pylint \
      -f '$format' \
      $(eval echo "${LINTBALL__WRITE_ARGS__PYLINT}") \
      '$path'"
  else
    echo "pylint \
      -f '$format' \
      $(eval echo "${LINTBALL__CHECK_ARGS__PYLINT}") \
      '$path'"
  fi
}

cmd_rubocop() {
  local mode path color
  mode="${1#mode=}"
  path="${2#path=}"

  # show colors in output only if interactive shell
  color="--no-color"
  if [[ $- == *i* ]]; then
    color="--color"
  fi

  if [ "$mode" = "write" ]; then
    echo "bundle exec rubocop \
      $color \
      $(eval echo "${LINTBALL__WRITE_ARGS__RUBOCOP}") \
      '$path'"
  else
    echo "bundle exec rubocop \
      $color \
      $(eval echo "${LINTBALL__CHECK_ARGS__RUBOCOP}") \
      '$path'"
  fi
}

cmd_shfmt() {
  local mode path lang
  mode="${1#mode=}"
  path="${2#path=}"

  # shellcheck disable=SC2034
  lang="${3#lang=}"

  if [ "$mode" = "write" ]; then
    echo "shfmt \
      $(eval echo "${LINTBALL__WRITE_ARGS__SHFMT}") \
      '$path'"
  else
    echo "shfmt \
      $(eval echo "${LINTBALL__CHECK_ARGS__SHFMT}") \
      '$path'"
  fi
}

cmd_stylua() {
  local mode path
  mode="${1#mode=}"
  path="${2#path=}"

  if [ "$mode" = "write" ]; then
    echo "stylua \
      $(eval echo "${LINTBALL__WRITE_ARGS__STYLUA}") \
      '$path'"
  else
    echo "stylua \
      $(eval echo "${LINTBALL__CHECK_ARGS__STYLUA}") \
      '$path'"
  fi
}

cmd_yamllint() {
  local mode path format
  mode="${1#mode=}"
  path="${2#path=}"

  # show colors in output only if interactive shell
  format="auto"
  if [[ $- == *i* ]]; then
    format="colored"
  fi
  if [ "$mode" = "write" ]; then
    echo "yamllint \
      --format '$format' \
      $(eval echo "${LINTBALL__WRITE_ARGS__YAMLLINT}") \
      '$path'"
  else
    echo "yamllint \
      --format '$format' \
      $(eval echo "${LINTBALL__CHECK_ARGS__YAMLLINT}") \
      '$path'"
  fi
}
