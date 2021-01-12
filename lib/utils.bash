#!/usr/bin/env bash

# Use latest installed nodejs, via asdf
if [ -z "${ASDF_NODEJS_VERSION:-}" ] && [ -n "$(which asdf)" ]; then
  ASDF_NODEJS_VERSION="$(asdf list nodejs | sort | tail -n 1 | xargs || true)"
  export ASDF_NODEJS_VERSION
fi

# Use latest installed nim, via asdf
if [ -z "${ASDF_NIM_VERSION:-}" ] && [ -n "$(which asdf)" ]; then
  ASDF_NIM_VERSION="$(asdf list nim | sort | tail -n 1 | xargs || true)"
  export ASDF_NIM_VERSION
fi

LINTBALL_DIR="${LINTBALL_DIR:-"${HOME}/.lintball"}"
DOTS="..................................."

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
      '$path'"
  else
    echo "shfmt \
      -d \
      -i 2 \
      -s \
      -ci \
      -ln '$lang' \
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
      '$path'"
  else
    echo "autopep8 \
      --aggressive \
      --aggressive \
      --aggressive \
      --diff \
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
      '$path'"
  else
    echo "docformatter \
      --check \
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
      '$path'"
  else
    echo "isort \
      --profile black \
      --check-only \
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
      '$path'"
  else
    echo "autoflake \
      --check \
      --expand-star-imports \
      --remove-all-unused-imports \
      --remove-duplicate-keys \
      --remove-unused-variables \
      '$path'"
  fi
}

cmd_black() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "black '$path'"
  else
    echo "black --check '$path'"
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
    if [ "$status" -gt 0 ] && [ -n "$(cat "$stderr")" ]; then
      # Some error message
      printf "%s%s%s\n" "↳ ${linter}" "${DOTS:offset}" "⚠️   see below"
      cat "$stdout" 2>/dev/null
      cat "$stderr" 1>&2 2>/dev/null
      status=1
    elif [ "$write" = "no" ] && [ "$(head -n1 "$stdout" | head -c4)" = "--- " ] && [ "$(head -n2 "$stdout" | tail -n 1 | head -c4)" = "+++ " ]; then
      # cmd printed a patchfile to stdout, show it
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
  local write path lang stdout stderr status linter offset
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

  shellcheck \
    --external-sources \
    --format=tty \
    --shell="$lang" \
    --severity=style \
    --exclude=SC2164 \
    --color=always \
    "$path" \
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
      shellcheck \
        --format="diff" \
        --external-sources \
        --shell="$lang" \
        --severity=style \
        --exclude=SC2164 \
        --color=never \
        "$path" \
        1>"$patchfile" \
        2>"$patcherr"
      if [ -n "$(cat "$patchfile")" ]; then
        # Fix patchfile
        sed -i '' 's/^--- a\/\.\//--- a\//' "$patchfile"
        sed -i '' 's/^+++ b\/\.\//+++ b\//' "$patchfile"
        echo ">>> patchfile $(cat "$patchfile")"
        git apply "$patchfile" 1>/dev/null
        echo "<<<"
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

lint_nim() {
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
  case "$1" in
    *.md | *.yml | *.js | *.jsx | *.ts | *.tsx | *.html | *.css | *.scss | *.json | *.bats | *.bash | *.sh | *.py | *.pyx | *.pxd | *.pxi | *.nim)
      return 0
      ;;
    *)
      # Inspect hashbang
      case "$(hashbang "$path")" in
        */bin/sh | *bash | *bats | *python*)
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
  case "$path" in
    *.md | *.yml | *.js | *.jsx | *.ts | *.tsx | *.html | *.css | *.scss | *.json)
      echo "# $path"
      lint "prettier" "$write" "$path" || status=$?
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
    *.sh)
      # Inspect hashbang
      case "$(hashbang "$path")" in
        *bash)
          echo "# $path"
          lint "shfmt" "$write" "$path" "bash" || status=$?
          lint_shellcheck "$write" "$path" "bash" || status=$?
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
      lint_nim "$write" "$path" || status=$?
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
  if [[ $path =~ ^[^/\.] ]]; then
    # ensure relative paths (foo/bar) are prepended with ./ (./foo/bar) to
    # ensure that */foo/* ignore patterns will match.
    echo "./$path"
  else
    echo "$path"
  fi
}
