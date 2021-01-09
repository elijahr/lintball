#!/usr/bin/env bash

LINTBALL_DIR="${LINTBALL_DIR:-"${HOME}/.lintball"}"

fix_prettier() {
  local path original
  path="$1"
  original="$(cat "$path")"
  if npx --userconfig "${LINTBALL_DIR}/.npmrc" prettier -u -w "$path" 1>/dev/null 2>&1; then
    if [ "$(cat "$path")" = "$original" ]; then
      echo "↳ prettier     ok"
    else
      echo "↳ prettier     wrote"
    fi
  else
    echo "↳ prettier     error"
  fi
}

check_prettier() {
  local path
  path="$1"
  echo "# prettier $path"
  npx --userconfig "${LINTBALL_DIR}/.npmrc" prettier --check "$path"
}

fix_bash() {
  local path
  path="$1"
  if shfmt -d -i 2 -ci -ln bash -w "$path" >/dev/null; then
    echo "↳ shfmt        ok"
  else
    echo "↳ shfmt        wrote"
  fi
  patchfile="$(mktemp)"
  errfile="$(mktemp)"
  if shellcheck \
    --format=diff \
    --external-sources \
    --shell=bash \
    --severity=style \
    --exclude=SC2164 \
    "$path" \
    >"$patchfile" \
    2>"$errfile"; then
    if [ -n "$(cat "$patchfile")" ]; then
      git apply "$patchfile" >/dev/null
      echo "↳ shellcheck   wrote"
    else
      echo "↳ shellcheck   ok"
    fi
  else
    echo "↳ shellcheck   $(cat "$errfile")"
  fi
  rm "$patchfile"
  rm "$errfile"
}

check_bash() {
  local path shfmt_status
  path="$1"
  shfmt_status=0

  echo "# shfmt $path"
  shfmt -d -i 2 -ci -ln bash "$path" || shfmt_status=$?

  echo "# shellcheck $path"
  shellcheck \
    --external-sources \
    --shell=bash \
    --severity=style \
    --exclude=SC2164 \
    "$path"

  [ "$shfmt_status" = 0 ]
}

fix_bats() {
  local path
  path="$1"
  if shfmt -d -i 2 -ci -ln bats -w "$path" >/dev/null; then
    echo "↳ shfmt        ok"
  else
    echo "↳ shfmt        wrote"
  fi
}

check_bats() {
  local path
  path="$1"
  echo "# shfmt $path"
  shfmt -d -i 2 -ci -ln bats "$path"
}

fix_py() {
  local path
  path="$1"
  if [ -z "$(which autoflake)" ]; then
    echo "↳ autoflake    *not installed*"
  else
    if autoflake \
      --in-place \
      --remove-unused-variables \
      --remove-unused-imports \
      --expand-star-imports \
      --remove-duplicate-keys \
      --ignore-init-module-imports \
      "$path"; then
      echo "↳ autoflake    ok"
    else
      echo "↳ autoflake    wrote"
    fi
  fi
  if [ -z "$(which black)" ]; then
    echo "↳ black        *not installed*"
  else
    if black "$path"; then
      echo "↳ black        ok"
    else
      echo "↳ black        wrote"
    fi
  fi
}

check_py() {
  local path
  path="$1"
  echo "# autoflake $path"
  if [ -z "$(which autoflake)" ]; then
    echo "*not installed*"
  else
    autoflake \
      --check \
      --remove-unused-variables \
      --remove-unused-imports \
      --expand-star-imports \
      --remove-duplicate-keys \
      --ignore-init-module-imports \
      "$path"
  fi
  echo "# black $path"
  if [ -z "$(which black)" ]; then
    echo "*not installed*"
  else
    black --check "$path"
  fi
}

fix_nim() {
  local path prev
  path="$1"
  if [ -z "$(which nimpretty)" ]; then
    echo "↳ nimpretty    *not installed*"
  else
    prev="$(cat "$path")"
    nimpretty "$path"
    if [ "$prev" = "$(cat "$path")" ]; then
      echo "↳ nimpretty    ok"
    else
      echo "↳ nimpretty    wrote"
    fi
  fi
}

check_nim() {
  local path tmp patch
  path="$1"
  echo "# nimpretty $path"
  if [ -z "$(which nimpretty)" ]; then
    echo "*not installed*"
  else
    tmp="$(mktemp)"
    nimpretty "$path" --out:"$tmp"
    patch="$(diff -u "$path" "$tmp")"
    if [ -n "$patch" ]; then
      cat "$patch"
    fi
    rm "$tmp"
  fi
}

fix() {
  local path
  path="$1"
  echo "# $path"
  if [ "$LINTBALL_STAGED_ONLY" = "yes" ]; then
    if git diff --name-only | grep -qF "$path"; then
      # path has unstaged changes, so don't modify it
      echo "↳ unstaged changes, skipping"
      echo
      return
    fi
  fi
  case "$path" in
    *.md | *.yml | *.js | *.jsx | *.ts | *.tsx | *.html | *.css | *.scss | *.json) fix_prettier "$path" ;;
    *.bats) fix_bats "$path" ;;
    *.sh | *.bash) fix_bash "$path" ;;
    *.py | *.pyx,*.pxd,*.pxi) fix_py "$path" ;;
    *.nim) fix_nim "$path" ;;
    *)
      # Inspect hashbang
      case "$(head -n1 "$path")" in
        */bash | *env\ bash | /bin/sh) fix_bash "$path" ;;
        */bats | *env\ bats) fix_bats "$path" ;;
        */python* | *env\ python*) fix_py "$path" ;;
        *) echo "↳ no linter" ;;
      esac
      ;;
  esac
  echo
}

check() {
  local path
  path="$1"
  case "$path" in
    *.md | *.yml | *.js | *.jsx | *.ts | *.tsx | *.html | *.css | *.scss | *.json) check_prettier "$path" ;;
    *.bats) check_bats "$path" ;;
    *.sh | *.bash) check_bash "$path" ;;
    *.py | *.pyx,*.pxd,*.pxi) check_py "$path" ;;
    *.nim) check_nim "$path" ;;
    *)
      # Inspect hashbang
      case "$(head -n1 "$path")" in
        */bash | *env\ bash | /bin/sh) check_bash "$path" ;;
        */bats | *env\ bats) check_bats "$path" ;;
        */python* | *env\ python*) check_py "$path" ;;
      esac
      ;;
  esac
}
