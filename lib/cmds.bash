cmd_autoflake() {
  local mode path autoflakeexe
  mode="${1//mode=/}"
  path="${2//path=/}"
  autoflakeexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/autoflake" ]; then
    autoflakeexe="${LINTBALL_DIR}/tools/python-env/bin/autoflake"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/autoflake.exe" ]; then
    autoflakeexe="${LINTBALL_DIR}/tools/python-env/Scripts/autoflake.exe"
  else
    echo "Could not find autoflake executable" >&2
    return 1
  fi
  if [ "$mode" = "write" ]; then
    echo "${autoflakeexe} \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOFLAKE}") \
      '$path'"
  else
    echo "${autoflakeexe} \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOFLAKE}") \
      '$path'"
  fi
}

cmd_autopep8() {
  local mode path autopep8exe
  mode="${1//mode=/}"
  path="${2//path=/}"
  autopep8exe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/autopep8" ]; then
    autopep8exe="${LINTBALL_DIR}/tools/python-env/bin/autopep8"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/autopep8.exe" ]; then
    autopep8exe="${LINTBALL_DIR}/tools/python-env/Scripts/autopep8.exe"
  else
    echo "Could not find autopep8 executable" >&2
    return 1
  fi
  if [ "$mode" = "write" ]; then
    echo "${autopep8exe} \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOPEP8}") \
      '$path'"
  else
    echo "${autopep8exe} \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOPEP8}") \
      '$path'"
  fi
}

cmd_black() {
  local mode path blackexe
  mode="${1//mode=/}"
  path="${2//path=/}"
  blackexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/black" ]; then
    blackexe="${LINTBALL_DIR}/tools/python-env/bin/black"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/black.exe" ]; then
    blackexe="${LINTBALL_DIR}/tools/python-env/Scripts/black.exe"
  else
    echo "Could not find black executable" >&2
    return 1
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
  local mode path docformatterexe
  mode="${1//mode=/}"
  path="${2//path=/}"
  docformatterexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/docformatter" ]; then
    docformatterexe="${LINTBALL_DIR}/tools/python-env/bin/docformatter"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/docformatter.exe" ]; then
    docformatterexe="${LINTBALL_DIR}/tools/python-env/Scripts/docformatter.exe"
  else
    echo "Could not find docformatter executable" >&2
    return 1
  fi
  if [ "$mode" = "write" ]; then
    echo "${docformatterexe} \
      $(eval echo "${LINTBALL__WRITE_ARGS__DOCFORMATTER}") \
      '$path'"
  else
    echo "${docformatterexe} \
      $(eval echo "${LINTBALL__CHECK_ARGS__DOCFORMATTER}") \
      '$path'"
  fi
}

cmd_isort() {
  local mode path isortexe
  mode="${1//mode=/}"
  path="${2//path=/}"
  isortexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/isort" ]; then
    isortexe="${LINTBALL_DIR}/tools/python-env/bin/isort"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/isort.exe" ]; then
    isortexe="${LINTBALL_DIR}/tools/python-env/Scripts/isort.exe"
  else
    echo "Could not find isort executable" >&2
    return 1
  fi
  if [ "$mode" = "write" ]; then
    echo "${isortexe} \
      $(eval echo "${LINTBALL__WRITE_ARGS__ISORT}") \
      '$path'"
  else
    echo "${isortexe} \
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

cmd_pylint() {
  local mode path format pylintexe
  mode="${1//mode=/}"
  path="${2//path=/}"

  # show colors in output only if interactive shell
  format="text"
  if [[ $- == *i* ]]; then
    format="colorized"
  fi
  pylintexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/pylint" ]; then
    pylintexe="${LINTBALL_DIR}/tools/python-env/bin/pylint"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/pylint.exe" ]; then
    pylintexe="${LINTBALL_DIR}/tools/python-env/Scripts/pylint.exe"
  else
    echo "Could not find pylint executable" >&2
    return 1
  fi
  if [ "$mode" = "write" ]; then
    echo "${pylintexe} \
      -f '$format' \
      $(eval echo "${LINTBALL__WRITE_ARGS__PYLINT}") \
      '$path'"
  else
    echo "${pylintexe} \
      -f '$format' \
      $(eval echo "${LINTBALL__CHECK_ARGS__PYLINT}") \
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
  local mode path format yamllintexe
  mode="${1//mode=/}"
  path="${2//path=/}"

  # show colors in output only if interactive shell
  format="auto"
  if [[ $- == *i* ]]; then
    format="colored"
  fi
  yamllintexe=""
  if [ -f "${LINTBALL_DIR}/tools/python-env/bin/yamllint" ]; then
    yamllintexe="${LINTBALL_DIR}/tools/python-env/bin/yamllint"
  elif [ -f "${LINTBALL_DIR}/tools/python-env/Scripts/yamllint.exe" ]; then
    yamllintexe="${LINTBALL_DIR}/tools/python-env/Scripts/yamllint.exe"
  else
    echo "Could not find yamllint executable" >&2
    return 1
  fi
  if [ "$mode" = "write" ]; then
    echo "${yamllintexe} \
      --format '$format' \
      $(eval echo "${LINTBALL__WRITE_ARGS__YAMLLINT}") \
      '$path'"
  else
    echo "${yamllintexe} \
      --format '$format' \
      $(eval echo "${LINTBALL__CHECK_ARGS__YAMLLINT}") \
      '$path'"
  fi
}
