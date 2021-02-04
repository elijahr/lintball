cmd_autoflake() {
  local mode path
  mode="${1//mode=/}"
  path="${2//path=/}"
  autoflake=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/autoflake" ]; then
    autoflake="${LINTBALL_DIR}/tools/python-env/bin/autoflake"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/autoflake.exe" ]; then
    autoflake="${LINTBALL_DIR}/tools/python-env/Scripts/autoflake.exe"
  fi
  if [ "$mode" = "write" ]; then
    echo "${autoflake} \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOFLAKE}") \
      '$path'"
  else
    echo "${autoflake} \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOFLAKE}") \
      '$path'"
  fi
}

cmd_autopep8() {
  local mode path
  mode="${1//mode=/}"
  path="${2//path=/}"
  autopep8=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/autopep8" ]; then
    autopep8="${LINTBALL_DIR}/tools/python-env/bin/autopep8"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/autopep8.exe" ]; then
    autopep8="${LINTBALL_DIR}/tools/python-env/Scripts/autopep8.exe"
  else
    echo "Could not find autopep8 executable" >&2
    return 1
  fi 
  if [ "$mode" = "write" ]; then
    echo "${autopep8} \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOPEP8}") \
      '$path'"
  else
    echo "${autopep8} \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOPEP8}") \
      '$path'"
  fi
}

cmd_black() {
  local mode path
  mode="${1//mode=/}"
  path="${2//path=/}"
  blackexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/black" ]; then
    blackexe="${LINTBALL_DIR}/tools/python-env/bin/black"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/black.exe" ]; then
    blackexe="${LINTBALL_DIR}/tools/python-env/Scripts/black.exe"
  fi  
  if [ "$mode" = "write" ]; then
    echo "${blackexe} \
      $(eval echo "${LINTBALL__WRITE_ARGS__BLACK}") \
      '$path'"
  else
    echo "${blackexe} \
      $(eval echo "${LINTBALL__CHECK_ARGS__BLACK}") \
      '$path'"
  fi
}

cmd_clippy() {
  local mode path dir
  mode="${1//mode=/}"
  path="${2//path=/}"
  # path is Cargo.toml, so cd to containing directory to run clippy
  dir="$(dirname "$path")"
  if [ "$mode" = "write" ]; then
    echo "(cd '$dir'; cargo clippy \
      $(eval echo "${LINTBALL__WRITE_ARGS__CLIPPY}"))"
  else
    echo "(cd '$dir'; cargo clippy \
      $(eval echo "${LINTBALL__CHECK_ARGS__CLIPPY}"))"
  fi
}

cmd_docformatter() {
  local mode path
  mode="${1//mode=/}"
  path="${2//path=/}"
  docformatter=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/docformatter" ]; then
    docformatter="${LINTBALL_DIR}/tools/python-env/bin/docformatter"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/docformatter.exe" ]; then
    docformatter="${LINTBALL_DIR}/tools/python-env/Scripts/docformatter.exe"
  else
    echo "Could not find docformatter executable" >&2
    return 1
  fi  
  if [ "$mode" = "write" ]; then
    echo "${docformatter} \
      $(eval echo "${LINTBALL__WRITE_ARGS__DOCFORMATTER}") \
      '$path'"
  else
    echo "${docformatter} \
      $(eval echo "${LINTBALL__CHECK_ARGS__DOCFORMATTER}") \
      '$path'"
  fi
}

cmd_isort() {
  local mode path
  mode="${1//mode=/}"
  path="${2//path=/}"
  isort=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/isort" ]; then
    isort="${LINTBALL_DIR}/tools/python-env/bin/isort"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/isort.exe" ]; then
    isort="${LINTBALL_DIR}/tools/python-env/Scripts/isort.exe"
  fi  
  if [ "$mode" = "write" ]; then
    echo "${isort} \
      $(eval echo "${LINTBALL__WRITE_ARGS__ISORT}") \
      '$path'"
  else
    echo "${isort} \
      $(eval echo "${LINTBALL__CHECK_ARGS__ISORT}") \
      '$path'"
  fi
}

cmd_prettier() {
  local mode path
  mode="${1//mode=/}"
  path="${2//path=/}"
  if [ "$mode" = "write" ]; then
    echo "npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__WRITE_ARGS__PRETTIER}") \
      '$path'"
  else
    echo "npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier \
      --path='$(pwd)' \
      -- \
      --check \
      $(eval echo "${LINTBALL__CHECK_ARGS__PRETTIER}") \
      '$path'"
  fi
}

cmd_rubocop() {
  local mode path color
  mode="${1//mode=/}"
  path="${2//path=/}"

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
  mode="${1//mode=/}"
  path="${2//path=/}"

  # shellcheck disable=SC2034
  lang="$3"

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
  mode="${1//mode=/}"
  path="${2//path=/}"

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
  mode="${1//mode=/}"
  path="${2//path=/}"

  # show colors in output only if interactive shell
  format="auto"
  if [[ $- == *i* ]]; then
    format="colored"
  fi
  if [ "$mode" = "write" ]; then
    echo "${LINTBALL_DIR}/tools/python-env/bin/yamllint \
      --format '$format' \
      $(eval echo "${LINTBALL__WRITE_ARGS__YAMLLINT}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/tools/python-env/bin/yamllint \
      --format '$format' \
      $(eval echo "${LINTBALL__CHECK_ARGS__YAMLLINT}") \
      '$path'"
  fi
}
