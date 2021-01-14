#!/usr/bin/env bash

LINTBALL_DIR="${LINTBALL_DIR:-"${HOME}/.lintball"}"
DOTS="..................................."

LINTBALL_IGNORES=()

cmd_prettier() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
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

cmd_prettier_eslint() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__WRITE_ARGS__PRETTIER_ESLINT}") \
      '$path'"
  else
    echo "npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__CHECK_ARGS__PRETTIER_ESLINT}") \
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
    echo "rubocop \
      $color \
      $(eval echo "${LINTBALL__WRITE_ARGS__RUBOCOP}") \
      '$path'"
  else
    echo "rubocop \
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
    echo "autopep8 \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOPEP8}") \
      '$path'"
  else
    echo "autopep8 \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOPEP8}") \
      '$path'"
  fi
}

cmd_docformatter() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
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
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "isort \
      $(eval echo "${LINTBALL__WRITE_ARGS__ISORT}") \
      '$path'"
  else
    echo "isort \
      $(eval echo "${LINTBALL__CHECK_ARGS__ISORT}") \
      '$path'"
  fi
}

cmd_autoflake() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "autoflake \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOFLAKE}") \
      '$path'"
  else
    echo "autoflake \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOFLAKE}") \
      '$path'"
  fi
}

cmd_black() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "black \
      $(eval echo "${LINTBALL__WRITE_ARGS__BLACK}") \
      '$path'"
  else
    echo "black \
      $(eval echo "${LINTBALL__CHECK_ARGS__BLACK}") \
      '$path'"
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

lint() {
  local linter write path original cmd stdout stderr status offset
  linter="$1"
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
    export LC_CTYPE=C
    if [ "$(tr '\0' '\n' <"$path" | head -c2 2>/dev/null)" = "#!" ]; then
      head -n1 "$path"
    fi
  )
}

assert_handled_path() {
  local path="$1"
  case "$(basename "$path")" in
    *.md | *.yml | *.yaml | *.js | *.jsx | *.ts | *.tsx | *.html | *.css | *.scss | *.json | *.bats | *.bash | *.sh | *.py | *.pyx | *.pxd | *.pxi | *.nim | *.rb | Gemfile)
      return 0
      ;;
    *)
      # Inspect shebang
      case "$(shebang "$path")" in
        */bin/sh | *bash | *bats | *python* | *ruby*)
          return 0
          ;;
      esac
      ;;
  esac
  return 1
}

lint_any() {
  local write path status
  write="$1"
  path="$2"
  echo "$path"

  status=0
  path="$(normalize_path "$path")"
  case "$(basename "$path")" in
    *.md | *.html | *.css | *.scss | *.json)
      echo "# $path"
      lint "prettier" "$write" "$path" || status=$?
      echo
      ;;
    *.js | *.jsx | *.ts | *.tsx)
      echo "# $path"
      lint "prettier-eslint" "$write" "$path" || status=$?
      echo
      ;;
    *.yml | *.yaml)
      echo "# $path"
      lint "prettier" "$write" "$path" || status=$?
      lint "yamllint" "$write" "$path" || status=$?
      echo
      ;;
    *.bats)
      echo "# $path"
      lint "shfmt" "$write" "$path" "bats" || status=$?
      echo
      ;;
    *.bash)
      echo "# $path"
      lint "shfmt" "$write" "$path" "bash" || status=$?
      lint_shellcheck "$write" "$path" "bash" || status=$?
      echo
      ;;
    *.dash)
      echo "# $path"
      lint "shfmt" "$write" "$path" "posix" || status=$?
      lint_shellcheck "$write" "$path" "dash" || status=$?
      echo
      ;;
    *.ksh | *.mksh)
      echo "# $path"
      lint "shfmt" "$write" "$path" "mksh" || status=$?
      lint_shellcheck "$write" "$path" "ksh" || status=$?
      echo
      ;;
    *.sh)
      # Inspect shebang
      case "$(shebang "$path")" in
        *bash)
          echo "# $path"
          lint "shfmt" "$write" "$path" "bash" || status=$?
          lint_shellcheck "$write" "$path" "bash" || status=$?
          echo
          ;;
        *dash)
          echo "# $path"
          lint "shfmt" "$write" "$path" "posix" || status=$?
          lint_shellcheck "$write" "$path" "dash" || status=$?
          echo
          ;;
        *ksh)
          echo "# $path"
          lint "shfmt" "$write" "$path" "mksh" || status=$?
          lint_shellcheck "$write" "$path" "ksh" || status=$?
          echo
          ;;
        *)
          echo "# $path"
          lint "shfmt" "$write" "$path" "posix" || status=$?
          lint_shellcheck "$write" "$path" "sh" || status=$?
          echo
          ;;
      esac
      ;;
    *.py)
      echo "# $path"
      lint "docformatter" "$write" "$path" || status=$?
      lint "autopep8" "$write" "$path" || status=$?
      lint "autoflake" "$write" "$path" || status=$?
      lint "isort" "$write" "$path" || status=$?
      lint "black" "$write" "$path" || status=$?
      echo
      ;;
    *.pyx | *.pxd | *.pxi)
      echo "# $path"
      lint "docformatter" "$write" "$path" || status=$?
      lint "autopep8" "$write" "$path" || status=$?
      lint "autoflake" "$write" "$path" || status=$?
      echo
      ;;
    *.nim)
      echo "# $path"
      lint_nimpretty "$write" "$path" || status=$?
      echo
      ;;
    *.rb | Gemfile)
      echo "# $path"
      lint "rubocop" "$write" "$path" || status=$?
      echo
      ;;
    *)
      # Inspect shebang
      case "$(shebang "$path")" in
        */bin/sh)
          echo "# $path"
          lint "shfmt" "$write" "$path" "posix" || status=$?
          lint_shellcheck "$write" "$path" "sh" || status=$?
          echo
          ;;
        *bash)
          echo "# $path"
          lint "shfmt" "$write" "$path" "bash" || status=$?
          lint_shellcheck "$write" "$path" "bash" || status=$?
          echo
          ;;
        *bats)
          echo "# $path"
          lint "shfmt" "yes" "$path" "bats" || status=$?
          echo
          ;;
        *python*)
          echo "# $path"
          lint "docformatter" "$write" "$path" || status=$?
          lint "autopep8" "$write" "$path" || status=$?
          lint "autoflake" "$write" "$path" || status=$?
          lint "isort" "$write" "$path" || status=$?
          lint "black" "$write" "$path" || status=$?
          echo
          ;;
        *ruby*)
          echo "# $path"
          lint "rubocop" "$write" "$path" || status=$?
          echo
          ;;
      esac
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
      write_args* | check_args*)
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

load_config "${LINTBALL_DIR}/configs/lintballrc.json"
