#!/usr/bin/env bash

LINTBALL_DIR="${LINTBALL_DIR:-"${HOME}/.lintball"}"

DOTS="..................................."
LINTBALL_IGNORES=()
LINTBALL_WRITE="no"
LINTBALL_LIST="no"
LINTBALL_CONFIG=""
LINTBALL_ANSWER=""

export LINTBALL_DIR LINTBALL_WRITE LINTBALL_LIST LINTBALL_CONFIG LINTBALL_ANSWER

# For rubocop
BUNDLE_GEMFILE="${LINTBALL_DIR}/deps/Gemfile"
export BUNDLE_GEMFILE

cmd_prettier() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "npm \
      --prefix='${LINTBALL_DIR}/deps' \
      run \
      prettier \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__WRITE_ARGS__PRETTIER}") \
      '$path'"
  else
    echo "npm \
      --prefix='${LINTBALL_DIR}/deps' \
      run \
      prettier \
      --path='$(pwd)' \
      -- \
      --check \
      $(eval echo "${LINTBALL__CHECK_ARGS__PRETTIER}") \
      '$path'"
  fi
}

cmd_stylua() {
  local write path
  write="$1"
  path="$2"

  if [ "$write" = "yes" ]; then
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
  local write path format
  write="$1"
  path="$2"

  # show colors in output only if interactive shell
  format="auto"
  if [[ $- == *i* ]]; then
    format="colored"
  fi
  if [ "$write" = "yes" ]; then
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

cmd_rubocop() {
  local write path color
  write="$1"
  path="$2"

  # show colors in output only if interactive shell
  color="--no-color"
  if [[ $- == *i* ]]; then
    color="--color"
  fi

  if [ "$write" = "yes" ]; then
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
  local write path lang
  write="$1"
  path="$2"
  lang="$3"

  if [ "$write" = "yes" ]; then
    echo "shfmt \
      $(eval echo "${LINTBALL__WRITE_ARGS__SHFMT}") \
      '$path'"
  else
    echo "shfmt \
      $(eval echo "${LINTBALL__CHECK_ARGS__SHFMT}") \
      '$path'"
  fi
}

cmd_autopep8() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/deps/python-env/bin/autopep8 \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOPEP8}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/deps/python-env/bin/autopep8 \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOPEP8}") \
      '$path'"
  fi
}

cmd_docformatter() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/deps/python-env/bin/docformatter \
      $(eval echo "${LINTBALL__WRITE_ARGS__DOCFORMATTER}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/deps/python-env/bin/docformatter \
      $(eval echo "${LINTBALL__CHECK_ARGS__DOCFORMATTER}") \
      '$path'"
  fi
}

cmd_isort() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/deps/python-env/bin/isort \
      $(eval echo "${LINTBALL__WRITE_ARGS__ISORT}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/deps/python-env/bin/isort \
      $(eval echo "${LINTBALL__CHECK_ARGS__ISORT}") \
      '$path'"
  fi
}

cmd_autoflake() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/deps/python-env/bin/autoflake \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOFLAKE}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/deps/python-env/bin/autoflake \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOFLAKE}") \
      '$path'"
  fi
}

cmd_black() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/deps/python-env/bin/black \
      $(eval echo "${LINTBALL__WRITE_ARGS__BLACK}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/deps/python-env/bin/black \
      $(eval echo "${LINTBALL__CHECK_ARGS__BLACK}") \
      '$path'"
  fi
}

cmd_clippy() {
  local write path dir
  write="$1"
  path="$2"
  # path is Cargo.toml, so cd to containing directory to run clippy
  dir="$(dirname "$path")"
  if [ "$write" = "yes" ]; then
    echo "(cd '$dir'; cargo clippy \
      $(eval echo "${LINTBALL__WRITE_ARGS__CLIPPY}"))"
  else
    echo "(cd '$dir'; cargo clippy \
      $(eval echo "${LINTBALL__CHECK_ARGS__CLIPPY}"))"
  fi
}

lint_shellcheck() {
  local write path args lang stdout stderr status linter offset color
  write="$1"
  path="$2"
  lang="$3"

  if [ "$write" = "yes" ]; then
    args="${LINTBALL__WRITE_ARGS__SHELLCHECK}"
  else
    args="${LINTBALL__CHECK_ARGS__SHELLCHECK}"
  fi

  linter="shellcheck"
  offset="${#linter}"
  stdout="$(mktemp)"
  stderr="$(mktemp)"
  patchfile="$(mktemp)"
  patcherr="$(mktemp)"
  status=0

  # show colors in output only if interactive shell
  color="never"
  if [[ $- == *i* ]]; then
    color="always"
  fi

  set -f
  eval "shellcheck \
    --format=tty \
    --color=$color \
    $(eval echo "$args") \
    '$path'" \
    1>"$stdout" \
    2>"$stderr" || status=$?
  set +f

  if [ "$status" -eq 0 ]; then
    # File has no issues
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "ok"
  else
    # stdout contains the lint results
    # stderr contains an error message
    if [ "$write" = "yes" ] && [ -n "$(cat "$stdout" 2>/dev/null)" ]; then
      # patchable, so generate a patchfile and apply it
      set -f
      eval "shellcheck \
        --format=diff \
        --color=never \
        $(eval echo "$args") \
        '$path'" \
        1>"$patchfile" \
        2>"$patcherr"
      set +f
      if [ -n "$(cat "$patchfile")" ]; then
        # Fix patchfile
        sed -i '' 's/^--- a\/\.\//--- a\//' "$patchfile"
        sed -i '' 's/^+++ b\/\.\//+++ b\//' "$patchfile"
        git apply "$patchfile" 1>/dev/null
        printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "wrote"
        status=0
      else
        if [ -n "$(cat "$patcherr")" ]; then
          # not patchable, show output from initial shellcheck run
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
          cat "$stdout"
        else
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "unknown error"
        fi
      fi
    else
      # not patchable, show error
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
      cat "$stdout" 2>/dev/null
      cat "$stderr" 1>&2 2>/dev/null
    fi
  fi
  rm "$stdout"
  rm "$stderr"
  rm "$patchfile"
  rm "$patcherr"
  return $status
}

lint_nimpretty() {
  local write path args tmp patch stdout stderr status linter offset
  write="$1"
  path="$2"

  if [ "$write" = "yes" ]; then
    args="${LINTBALL__WRITE_ARGS__NIMPRETTY}"
  else
    args="${LINTBALL__CHECK_ARGS__NIMPRETTY}"
  fi

  linter="nimpretty"
  offset="${#linter}"

  if [ -z "$(which nimpretty)" ]; then
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "😵 not installed"
    return 1
  fi

  tmp="$(mktemp)"
  stdout="$(mktemp)"
  stderr="$(mktemp)"
  status=0

  set -f
  eval "nimpretty \
    ""$path"" \
    --out:'$tmp' \
    $(eval echo "$args")" \
    1>"$stdout" \
    2>"$stderr" || status=$?
  set +f
  if [ "$status" -eq 0 ]; then
    if [ "$(cat "$tmp")" = "$(cat "$path")" ]; then
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "ok"
    else
      patch="$(diff -u "$path" "$tmp")"
      if [ -n "$patch" ]; then
        if [ "$write" = "yes" ]; then
          cat "$tmp" >"$path"
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "wrote"
        else
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
          echo "$patch"
          status=1
        fi
      else
        printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
        cat "$stdout" 2>/dev/null
        cat "$stderr" 1>&2 2>/dev/null
      fi
    fi
  else
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
    cat "$stdout" 2>/dev/null
    cat "$stderr" 1>&2 2>/dev/null
  fi
  rm "$tmp"
  rm "$stdout"
  rm "$stderr"
  return $status
}

lint_prettier_eslint() {
  local write path linter offset cmd stdout stderr status
  write="$1"
  path="$2"

  linter="prettier-eslint"
  offset="${#linter}"

  if [ "$write" = "yes" ]; then
    cmd="npm \
      --prefix='${LINTBALL_DIR}/deps' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__WRITE_ARGS__PRETTIER_ESLINT}") \
      '$path'"
  else
    cmd="npm \
      --prefix='${LINTBALL_DIR}/deps' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__CHECK_ARGS__PRETTIER_ESLINT}") \
      '$path'"
  fi

  stdout="$(mktemp)"
  stderr="$(mktemp)"
  status=0

  set -f
  eval "$cmd" \
    1>"$stdout" \
    2>"$stderr" || status=$?
  set +f
  if [ "$status" -eq 0 ]; then
    if [ "$(cat "$stdout")" = "$(cat "$path")" ]; then
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "ok"
    else
      patch="$(diff -u "$path" "$stdout")"
      if [ -n "$patch" ]; then
        if [ "$write" = "yes" ]; then
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "wrote"
        else
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
          echo "$patch"
          cat "$stderr" 1>&2 2>/dev/null
          status=1
        fi
      else
        printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
        cat "$stdout" 2>/dev/null
        cat "$stderr" 1>&2 2>/dev/null
      fi
    fi
  else
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
    cat "$stdout" 2>/dev/null
    cat "$stderr" 1>&2 2>/dev/null
  fi
  rm "$stdout"
  rm "$stderr"
  return $status
}

lint_uncrustify() {
  local write path lang args patch stdout stderr status linter offset
  write="$1"
  path="$2"
  lang="$3"

  if [ "$write" = "yes" ]; then
    args="${LINTBALL__WRITE_ARGS__UNCRUSTIFY}"
  else
    args="${LINTBALL__CHECK_ARGS__UNCRUSTIFY}"
  fi

  linter="uncrustify"
  offset="${#linter}"

  if [ -z "$(which uncrustify)" ]; then
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "😵 not installed"
    return 1
  fi

  stdout="$(mktemp)"
  stderr="$(mktemp)"
  status=0

  set -f
  eval "uncrustify \
    $(eval echo "$args") \
    -f '$path'" \
    1>"$stdout" \
    2>"$stderr" || status=$?
  set +f
  if [ "$status" -eq 0 ]; then
    if [ "$(cat "$stdout")" = "$(cat "$path")" ]; then
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "ok"
    else
      patch="$(diff -u "$path" "$stdout")"
      if [ -n "$patch" ]; then
        if [ "$write" = "yes" ]; then
          cat "$stdout" >"$path"
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "wrote"
        else
          printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
          echo "$patch"
          status=1
        fi
      else
        printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
        cat "$stdout" 2>/dev/null
        cat "$stderr" 1>&2 2>/dev/null
      fi
    fi
  else
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
    cat "$stderr" 1>&2 2>/dev/null
  fi
  rm "$stdout"
  rm "$stderr"
  return $status
}

lint() {
  local linter write path original cmd stdout stderr status offset
  linter="${1//-/_}"
  write="$2"
  path="$3"
  lang="${4:-}"

  offset="${#linter}"
  original="$(cat "$path")"
  stdout="$(mktemp)"
  stderr="$(mktemp)"
  cmd="$(cmd_"$linter" "$write" "$path" "$lang")"
  status=0

  set -f
  eval "$cmd" 1>"$stdout" 2>"$stderr" || status=$?
  set +f
  if [ "$(cat "$path")" = "$original" ]; then
    if [ "$status" -gt 0 ] || {
      [ "$write" = "no" ] &&
        [ "$(head -n1 "$stdout" | head -c4)" = "--- " ] &&
        [ "$(head -n2 "$stdout" | tail -n 1 | head -c4)" = "+++ " ]
    }; then
      # Some error message
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
      cat "$stdout" 2>/dev/null
      cat "$stderr" 1>&2 2>/dev/null
      status=1
    else
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "ok"
    fi
  else
    status=0
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "wrote"
  fi
  rm "$stdout"
  rm "$stderr"
  return $status
}

shebang() {
  local path
  path="$1"
  (
    LC_CTYPE="C"
    export LC_CTYPE
    if [ "$(tr '\0' '\n' <"$path" | head -c2 2>/dev/null)" = "#!" ]; then
      head -n1 "$path"
    fi
  )
}

infer_extension() {
  local path lang filename extension
  path="$1"

  # Check for `# lintball lang=foo` directives
  lang="$(grep '^# lintball lang=' "$path" | sed 's/^# lintball lang=//' | tr '[:upper:]' '[:lower:]')"
  case "$lang" in
    cython)
      echo "pyx"
      return 0
      ;;
    javascript)
      echo "js"
      return 0
      ;;
    markdown)
      echo "md"
      return 0
      ;;
    python)
      echo "py"
      return 0
      ;;
    ruby)
      echo "rb"
      return 0
      ;;
    typescript)
      echo "ts"
      return 0
      ;;
    yaml)
      echo "yml"
      return 0
      ;;
    *)
      if [ -n "$lang" ]; then
        extension="$lang"
      else
        filename="$(basename "$path")"
        if [ "$filename" = "Gemfile" ]; then
          echo "rb"
          return 0
        fi
        extension="${filename##*.}"
      fi
      ;;
  esac

  case "$extension" in
    bash | bats | c | cpp | cs | css | d | dash | graphql | h | hpp | html | \
      jade | java | js | json | jsx | ksh | lua | m | M | md | mksh | mm | \
      nim | pug | pxd | pxi | py | pyx | rb | rs | scss | toml | ts | tsx | \
      xml | yml)
      echo "$extension"
      ;;
    sh)
      # Inspect shebang
      case "$(shebang "$path")" in
        *bash) echo "bash" ;;
        *dash) echo "dash" ;;
        *ksh) echo "ksh" ;;
        *) echo "sh" ;;
      esac
      ;;
    yaml) echo "yml" ;;
    *)
      # Inspect shebang
      case "$(shebang "$path")" in
        */bin/sh) echo "sh" ;;
        *bash) echo "bash" ;;
        *bats) echo "bats" ;;
        *dash) echo "dash" ;;
        *ksh) echo "ksh" ;;
        *node* | *deno*) echo "js" ;;
        *python*) echo "py" ;;
        *ruby*) echo "rb" ;;
      esac
      ;;
  esac
}

assert_handled_path() {
  if test -z "$(infer_extension "$1")"; then
    return 1
  fi
}

shfmt_lang() {
  local extension
  extension="$1"
  case "$extension" in
    ksh) echo "mksh" ;;
    sh | dash) echo "posix" ;;
    *) echo "$extension" ;;
  esac
}

shellcheck_lang() {
  local extension
  extension="$1"
  case "$extension" in
    mksh) echo "ksh" ;;
    *) echo "$extension" ;;
  esac
}

uncrustify_lang() {
  local extension
  extension="$1"
  case "$extension" in
    c | h) echo "c" ;;
    cs | cpp | d | hpp) echo "cpp" ;;
    m | mm | M) echo "objc" ;;
  esac
}

lint_any() {
  local write path status extension
  write="$1"
  path="$2"

  status=0
  path="$(normalize_path "$path")"
  extension="$(infer_extension "$path")"

  case "$extension" in
    css | graphql | html | jade | java | json | md | pug | scss | xml)
      if [ "$LINTBALL__USE__PRETTIER" = "true" ]; then
        echo "# $path"
        lint "prettier" "$write" "$path" || status=$?
        echo
      fi
      ;;
    bash | bats | dash | ksh | mksh | sh)
      if [ "$LINTBALL__USE__SHFMT" = "true" ] || [ "$LINTBALL__USE__SHELLCHECK" = "true" ]; then
        echo "# $path"
        if [ "$LINTBALL__USE__SHFMT" = "true" ]; then
          lint "shfmt" "$write" "$path" "$(shfmt_lang "$extension")" || status=$?
        fi
        if [ "$LINTBALL__USE__SHELLCHECK" = "true" ]; then
          lint_shellcheck "$write" "$path" "$(shellcheck_lang "$extension")" || status=$?
        fi
        echo
      fi
      ;;
    c | cpp | cs | d | h | hpp | m | mm | M)
      if [ "$LINTBALL__USE__UNCRUSTIFY" = "true" ]; then
        echo "# $path"
        lint_uncrustify "$write" "$path" "$(uncrustify_lang "$extension")" || status=$?
        echo
      fi
      ;;
    js | jsx | ts | tsx)
      if [ "$LINTBALL__USE__PRETTIER_ESLINT" = "true" ]; then
        echo "# $path"
        lint_prettier_eslint "$write" "$path" || status=$?
        echo
      fi
      ;;
    lua)
      if [ "$LINTBALL__USE__STYLUA" = "true" ]; then
        echo "# $path"
        lint "stylua" "$write" "$path" || status=$?
        echo
      fi
      ;;
    nim)
      if [ "$LINTBALL__USE__NIMPRETTY" = "true" ]; then
        echo "# $path"
        lint_nimpretty "$write" "$path" || status=$?
        echo
      fi
      ;;
    py)
      if [ "$LINTBALL__USE__DOCFORMATTER" = "true" ] ||
        [ "$LINTBALL__USE__AUTOPEP8" = "true" ] ||
        [ "$LINTBALL__USE__AUTOFLAKE" = "true" ] ||
        [ "$LINTBALL__USE__ISORT" = "true" ] ||
        [ "$LINTBALL__USE__BLACK" = "true" ]; then
        echo "# $path"
        if [ "$LINTBALL__USE__DOCFORMATTER" = "true" ]; then
          lint "docformatter" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__AUTOPEP8" = "true" ]; then
          lint "autopep8" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__AUTOFLAKE" = "true" ]; then
          lint "autoflake" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__ISORT" = "true" ]; then
          lint "isort" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__BLACK" = "true" ]; then
          lint "black" "$write" "$path" || status=$?
        fi
        echo
      fi
      ;;
    pyx | pxd | pxi)
      if [ "$LINTBALL__USE__DOCFORMATTER" = "true" ] ||
        [ "$LINTBALL__USE__AUTOPEP8" = "true" ] ||
        [ "$LINTBALL__USE__AUTOFLAKE" = "true" ]; then
        echo "# $path"
        if [ "$LINTBALL__USE__DOCFORMATTER" = "true" ]; then
          lint "docformatter" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__AUTOPEP8" = "true" ]; then
          lint "autopep8" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__AUTOFLAKE" = "true" ]; then
          lint "autoflake" "$write" "$path" || status=$?
        fi
        echo
      fi
      ;;
    rb)
      if [ "$LINTBALL__USE__RUBOCOP" = "true" ] ||
        [ "$LINTBALL__USE__PRETTIER" = "true" ]; then
        echo "# $path"
        if [ "$LINTBALL__USE__RUBOCOP" = "true" ]; then
          lint "rubocop" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__PRETTIER" = "true" ]; then
          lint "prettier" "$write" "$path" || status=$?
        fi
        echo
      fi
      ;;
    toml)
      if [ "$LINTBALL__USE__CLIPPY" = "true" ] &&
        [ "$(basename "$path")" = "Cargo.toml" ]; then
        echo "# $path"
        # Special case for Rust package; clippy analyzes an entire crate, not a
        # single path, so when a Cargo.toml is encountered, use clippy.
        lint "clippy" "$write" "$path" || status=$?
      fi
      ;;
    yml)
      if [ "$LINTBALL__USE__PRETTIER" = "true" ] ||
        [ "$LINTBALL__USE__YAMLLINT" = "true" ]; then
        echo "# $path"
        if [ "$LINTBALL__USE__PRETTIER" = "true" ]; then
          lint "prettier" "$write" "$path" || status=$?
        fi
        if [ "$LINTBALL__USE__YAMLLINT" = "true" ]; then
          lint "yamllint" "$write" "$path" || status=$?
        fi
        echo
      fi
      ;;
  esac

  return $status
}

cmd_find() {
  local line
  printf 'find '
  if [ "$#" -eq 0 ]; then
    printf '"." '
  else
    echo "$@" | while read -r line; do
      printf '"%s" ' "$(normalize_path "$line")"
    done
  fi

  printf '"-type" "f" '

  for ignore in "${LINTBALL_IGNORES[@]}"; do
    printf '"-a" "(" "-not" "-path" "%s" ")" ' "$ignore"
  done

  printf '"-print" '
}

normalize_path() {
  local path
  path="$1"

  # Strip redundant slashes
  while [[ $path =~ \/\/ ]]; do
    path="${path//\/\//\/}"
  done

  # Strip trailing slash
  path="$(echo "$path" | sed 's/\/$//')"

  if [[ $path =~ ^[^/\.] ]]; then
    # ensure relative paths (foo/bar) are prepended with ./ (./foo/bar) to
    # ensure that */foo/* ignore patterns will match.
    echo "./$path"
  else
    echo "$path"
  fi
}

load_config() {
  local path name value line
  path="$(normalize_path "$1")"

  if [ ! -f "$path" ]; then
    echo -e "No config file at ${path}"
    return 1
  fi

  # Clear the ignores array
  LINTBALL_IGNORES=()

  while read -r line; do
    case "$line" in
      write_args* | check_args* | use*)
        if [ "$(echo "$line" | cut -f2)" = "object" ]; then
          continue
        fi
        name="LINTBALL__$(echo "$line" | awk '{ print $1 "__" $2 }' | sed 's/[^a-z0-9]/_/g' | tr '[:lower:]' '[:upper:]')"
        value="$(echo "$line" | awk -F $'\t' 'BEGIN {OFS = FS}{print $4}')"
        export "${name}=${value}"
        ;;
      ignores*)
        if [ "$(echo "$line" | cut -f2)" = "array" ]; then
          continue
        fi
        LINTBALL_IGNORES+=("$(echo "$line" | awk '{ print $4 }')")
        ;;
    esac
  done <<<"$(bash "${LINTBALL_DIR}/lib/jwalk/lib/jwalk.sh" <"$path")"
}

find_config() {
  local dir
  # Traverse up the directory tree looking for .lintballrc.json
  dir="$(pwd)"
  while [ "$dir" != "/" ]; do
    if [ -f "${dir}/.lintballrc.json" ]; then
      echo "${dir}/.lintballrc.json"
      break
    else
      dir="$(dirname "$dir")"
    fi
  done
}

usage() {
  cat <<EOF

█   █ █▄ █ ▀█▀ ██▄ ▄▀▄ █   █
█▄▄ █ █ ▀█  █  █▄█ █▀█ █▄▄ █▄▄
keep your code tidy with one command.

Usage: lintball [options] [command]

Options:
  -h, --help                Show this help message & exit.
  -v, --version             Print version & exit.
  -c, --config <path>       Use the $(.lintballrc.json) config file at <path>.

Commands:
  check [path …]            Recursively check for issues.
                            Exits with status 1 if any issues are found.
  fix [path …]              Recursively fix issues.
                            Exits with status 1 if any issues exist which cannot
                            be fixed.
  list [path …]             List files which lintball is configured for
                            checking. If [paths …] are provided, lintball will
                            echo back the subset of those paths which it would
                            check with the given configuration. Useful for
                            debugging the $(ignores) section of a
                            $(.lintballrc.json) config file.
  update                    Update lintball to the latest version.
  githooks [path]           Install lintball githooks in the working directory
                            or [path].
  lintballrc [path]         Place a default $(.lintballrc.json) config file in
                            the working directory or [path]

Examples:
  \$ lintball check          # Check the working directory for issues.
  \$ lintball fix            # Fix issues in the working directory.
  \$ lintball check foo      # Check the $(foo) directory for issues.
  \$ lintball fix foo        # Fix issues in the $(foo) directory.
  \$ lintball check foo.py   # Check the $(foo.py) file for issues.
  \$ lintball fix foo.py     # Fix issues in the $(foo.py) file.

Tools:

| Language     |                   Tools used                    |
| :----------- | :---------------------------------------------: |
| bash         |                shellcheck, shfmt                |
| bats         |                shellcheck, shfmt                |
| C            |                   uncrustify                    |
| C#           |                   uncrustify                    |
| C++          |                   uncrustify                    |
| D            |                   uncrustify                    |
| CSS          |                    prettier                     |
| Cython       |        autoflake, autopep8, docformatter        |
| dash         |                shellcheck, shfmt                |
| GraphQL      |                    prettier                     |
| HTML         |                    prettier                     |
| Java         |                  prettier-java                  |
| JavaScript   |                 prettier-eslint                 |
| JSON         |                    prettier                     |
| JSX          |                 prettier-eslint                 |
| ksh          |                shellcheck, shfmt                |
| Lua          |                     StyLua                      |
| Luau         |                     StyLua                      |
| Markdown     |                    prettier                     |
| Nim          |                    nimpretty                    |
| Objective-C  |                   uncrustify                    |
| package.json |              prettier-package-json              |
| pug          |              @prettier/plugin-pug               |
| Python       | autoflake, autopep8, black, docformatter, isort |
| Ruby         |         @prettier/plugin-ruby, rubocop          |
| Rust         |                     clippy                      |
| SASS         |                    prettier                     |
| sh           |                shellcheck, shfmt                |
| TSX          |                 prettier-eslint                 |
| TypeScript   |                 prettier-eslint                 |
| XML          |              @prettier/plugin-xml               |
| YAML         |               prettier, yamllint                |

Additional documentation can be found in ${LINTBALL_DIR}/README.md
or at https://github.com/elijahr/lintball

EOF
}

confirm_copy() {
  local src dest symlink
  src="$1"
  dest="$2"
  symlink="${3:-"no"}"
  if [ -d "$src" ] || [ -d "$dest" ]; then
    echo -e
    echo -e "Source and destination must be file paths, not directories."
    echo -e
    return 1
  fi
  if [ -f "$dest" ]; then
    if [ -n "$LINTBALL_ANSWER" ]; then
      answer="$LINTBALL_ANSWER"
    else
      read -rp "${dest//${HOME}/"~"} exists. Replace? [y/N] " answer
    fi
    case $answer in
      [yY]*) ;;
      *)
        echo -e
        echo -e "Cancelled"
        echo -e
        return 1
        ;;
    esac
  fi
  if [ ! -d "$(dirname "$dest")" ]; then
    mkdir -p "$(dirname "$dest")"
  fi
  if [ "$symlink" = "yes" ]; then
    rm -rf "$dest"
    ln -s "$src" "$dest"
    echo "Linked ${src//${HOME}/"~"} → ${dest//${HOME}/"~"}"
  else
    cp -Rf "$src" "$dest"
    echo "Copied ${src//${HOME}/"~"} → ${dest//${HOME}/"~"}"
  fi
}

find_git_dir() {
  local dir
  # Traverse up the directory tree looking for .git
  dir="$1"
  while [ "$dir" != "/" ]; do
    if [ -d "${dir}/.git" ]; then
      echo "${dir}/.git"
      break
    else
      dir="$(dirname "$dir")"
    fi
  done
}

githooks() {
  local git_dir hooks_path hook dest status tmp
  git_dir="$(find_git_dir "$1" || true)"
  if [ -z "$git_dir" ]; then
    echo -e
    echo -e "Could not find a .git directory at or above $1"
    echo -e
    exit 1
  fi

  hooks_path="$(git --git-dir="$git_dir" config --local core.hooksPath || true)"
  if [ -z "$hooks_path" ]; then
    hooks_path="${1}/.githooks"
  fi
  for hook in "${LINTBALL_DIR}/githooks/"*; do
    status=0
    dest="${hooks_path}/$(basename "$hook")"
    confirm_copy "$hook" "$dest" "yes" || status=$?
    if [ "$status" -gt 0 ]; then
      exit $status
    fi
  done
  git --git-dir="$git_dir" config --local core.hooksPath "$hooks_path"
  echo
  echo "Set git hooks path → $hooks_path"
  echo
  exit 0
}

lintballrc() {
  confirm_copy \
    "${LINTBALL_DIR}/configs/lintballrc-ignores.json" \
    "${1}/.lintballrc.json" || exit $?
}

check_or_fix() {
  local fix tmp line
  fix="$1"
  shift
  tmp="$(mktemp -d)"
  eval "$(cmd_find "$@")" | while read -r line; do
    if assert_handled_path "$line"; then
      lint_any "$fix" "$line" || touch "${tmp}/error"
    fi
  done

  status=0
  if [ -f "${tmp}/error" ]; then
    status=1
  fi
  rm -r "$tmp"
  exit "$status"
}

check() {
  check_or_fix "no" "$@"
}

fix() {
  check_or_fix "yes" "$@"
}

list() {
  local line
  eval "$(cmd_find "$@")" | sort -n | while read -r line; do
    if assert_handled_path "$line"; then
      line="$(normalize_path "$line")"
      echo "$line"
    fi
  done
}

entrypoint() {
  case "${1:-}" in
    -h | --help)
      usage
      exit 0
      ;;
    -v | --version)
      echo "v0.3.0"
      exit 0
      ;;
    -c | --config)
      shift
      LINTBALL_CONFIG="$1"
      export LINTBALL_CONFIG
      shift
      subcommand "$@"
      ;;
    -*)
      echo -e "Unknown switch $1"
      usage
      exit 1
      ;;
    *)
      LINTBALL_CONFIG="$(find_config)"
      export LINTBALL_CONFIG
      subcommand "$@"
      ;;
  esac
}

subcommand() {
  local command path

  if [ -z "${1:-}" ]; then
    echo -e
    echo -e "Missing subcommand"
    echo -e
    usage
    exit 1
  fi

  if [ -n "$LINTBALL_CONFIG" ]; then
    echo
    echo "# lintball: using config file ${LINTBALL_CONFIG}"
    echo
    load_config "$LINTBALL_CONFIG" || exit 1
  fi

  case "$1" in
    check | fix | list)
      command="$1"
      shift
      eval "$command" "$@"
      ;;
    update)
      exec "${LINTBALL_DIR}/install.sh"
      ;;
    githooks | lintballrc)
      command="${1//-/_}"
      shift
      case "${1:-}" in
        -y | --yes)
          LINTBALL_ANSWER="yes"
          export LINTBALL_ANSWER
          shift
          ;;
        -n | --no)
          LINTBALL_ANSWER="no"
          export LINTBALL_ANSWER
          shift
          ;;
      esac
      if [ "$#" -gt 1 ]; then
        echo -e
        echo -e "Illegal number of parameters"
        echo -e
        usage
      fi
      path="${1:-$PWD}"
      eval "$command" "$path"
      ;;
    *)
      echo -e
      echo -e "Unknown subcommand '$1'"
      echo -e
      usage
      ;;
  esac
}
