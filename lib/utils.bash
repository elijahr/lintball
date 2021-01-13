#!/usr/bin/env bash

LINTBALL_DIR="${LINTBALL_DIR:-"${HOME}/.lintball"}"
DOTS="..................................."

# So rubocop works
export BUNDLE_GEMFILE="${LINTBALL_DIR}/Gemfile"

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
      ${PRETTIER_ARGS:-} \
      --write \
      '$path'"
  else
    echo "npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier \
      --path='$(pwd)' \
      -- \
      --check \
      ${PRETTIER_ARGS:-} \
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
      --write \
      ${PRETTIER_ESLINT_ARGS:-} \
      '$path'"
  else
    echo "npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      ${PRETTIER_ESLINT_ARGS:-} \
      '$path'"
  fi
}

cmd_yamllint() {
  local write path format config
  write="$1"
  path="$2"

  # show colors in output only if interactive shell
  format="auto"
  if [[ $- == *i* ]]; then
    format="colored"
  fi

  # disable some rules that don't make sense for github workflows files
  config="{extends: default, rules: {document-start: disable, truthy: disable}}"
  echo "yamllint \
    --strict \
    --config-data '$config' \
    --format '$format' \
    ${YAMLLINT_ARGS:-} \
    '$path'"
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
      --auto-correct-all \
      $color \
      ${RUBOCOP_ARGS:-} \
      '$path'"
  else
    echo "rubocop \
      $color \
      ${RUBOCOP_ARGS:-} \
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
      -d \
      -i 2 \
      -s \
      -ci \
      -ln '$lang' \
      -w \
      ${SHFMT_ARGS:-} \
      '$path'"
  else
    echo "shfmt \
      -d \
      -i 2 \
      -s \
      -ci \
      -ln '$lang' \
      ${SHFMT_ARGS:-} \
      '$path'"
  fi
}

cmd_autopep8() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "autopep8 \
      --aggressive \
      --aggressive \
      --aggressive \
      --in-place \
      ${AUTOPEP8_ARGS:-} \
      '$path'"
  else
    echo "autopep8 \
      --aggressive \
      --aggressive \
      --aggressive \
      --diff \
      ${AUTOPEP8_ARGS:-} \
      '$path'"
  fi
}

cmd_docformatter() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "docformatter \
      --in-place \
      ${DOCFORMATTER_ARGS:-} \
      '$path'"
  else
    echo "docformatter \
      --check \
      ${DOCFORMATTER_ARGS:-} \
      '$path'"
  fi
}

cmd_isort() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "isort \
      --profile black \
      ${ISORT_ARGS:-} \
      '$path'"
  else
    echo "isort \
      --profile black \
      --check-only \
      ${ISORT_ARGS:-} \
      '$path'"
  fi
}

cmd_autoflake() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "autoflake \
      --in-place \
      --expand-star-imports \
      --remove-all-unused-imports \
      --remove-duplicate-keys \
      --remove-unused-variables \
      ${AUTOFLAKE_ARGS:-} \
      '$path'"
  else
    echo "autoflake \
      --check \
      --expand-star-imports \
      --remove-all-unused-imports \
      --remove-duplicate-keys \
      --remove-unused-variables \
      ${AUTOFLAKE_ARGS:-} \
      '$path'"
  fi
}

cmd_black() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "black ${BLACK_ARGS:-} '$path'"
  else
    echo "black --check ${BLACK_ARGS:-} '$path'"
  fi
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

  eval "$cmd" 1>"$stdout" 2>"$stderr" || status=$?
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

lint_shellcheck() {
  local write path lang stdout stderr status linter offset color
  write="$1"
  path="$2"
  lang="$3"

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

  eval "shellcheck \
    --external-sources \
    --format=tty \
    --shell=$lang \
    --severity=style \
    --exclude=SC2164 \
    --color=$color \
    ${SHELLCHECK_ARGS:-} \
    '$path'" \
    1>"$stdout" \
    2>"$stderr" || status=$?

  if [ "$status" -eq 0 ]; then
    # File has no issues
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "ok"
  else
    # stdout contains the lint results
    # stderr contains an error message
    if [ "$write" = "yes" ] && [ -n "$(cat "$stdout" 2>/dev/null)" ]; then
      # patchable, so generate a patchfile and apply it
      eval "shellcheck \
        --format=diff \
        --external-sources \
        --shell=$lang \
        --severity=style \
        --exclude=SC2164 \
        --color=never \
        ${SHELLCHECK_ARGS:-} \
        '$path'" \
        1>"$patchfile" \
        2>"$patcherr"
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
  local write path tmp patch stdout stderr status linter offset
  write="$1"
  path="$2"

  linter="nimpretty"
  offset="${#linter}"

  echo "# nimpretty $path"
  if [ -z "$(which nimpretty)" ]; then
    printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "😵 not installed"
    return 1
  fi

  tmp="$(mktemp)"
  stdout="$(mktemp)"
  stderr="$(mktemp)"
  status=0

  nimpretty \
    "$path" \
    --out:"$tmp" \
    "${NIMPRETTY_ARGS:-}" \
    1>"$stdout" \
    2>"$stderr" || status=$?
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

hashbang() {
  local path
  path="$1"
  if [ "$(head -c2 "$path" 2>/dev/null)" = "#!" ]; then
    head -n1 "$path"
  fi
}

assert_handled_path() {
  case "$(basename "$1")" in
    *.md | *.yml | *.yaml | *.js | *.jsx | *.ts | *.tsx | *.html | *.css | *.scss | *.json | *.bats | *.bash | *.sh | *.py | *.pyx | *.pxd | *.pxi | *.nim | *.rb | Gemfile)
      return 0
      ;;
    *)
      # Inspect hashbang
      case "$(hashbang "$path")" in
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
      # Inspect hashbang
      case "$(hashbang "$path")" in
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
      # Inspect hashbang
      case "$(hashbang "$path")" in
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
  local ignorefile dir
  printf 'find '
  if [ "$#" -eq 0 ]; then
    printf '"." '
  else
    while read -r path; do
      printf '"%s" ' "$(normalize_path "$path")"
    done <<<"$@"
  fi

  printf '"-type" "f" '

  # Traverse up the directory tree looking for .lintball-ignore,
  # default to lintball's lintball-ignore.defaults file.
  ignorefile="${LINTBALL_DIR}/lintball-ignore.defaults"
  dir="$(pwd)"
  while [ "$dir" != "/" ]; do
    if [ -f "${dir}/.lintball-ignore" ]; then
      ignorefile="${dir}/.lintball-ignore"
      break
    else
      dir="$(dirname "$dir")"
    fi
  done

  while read -r ignore; do
    # ignore comment lines
    if [[ $ignore =~ ^[^\#] ]]; then
      # strip trailing comments
      ignore="$(echo "$ignore" | sed 's/\(.*\)#.*/\1/' | xargs)"
      printf '"-a" "(" "-not" "-path" "%s" ")" ' "$ignore"
    fi
  done <<<"$(cat "$ignorefile")"
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
