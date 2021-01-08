#!/usr/bin/env bash

fix_prettier() {
  local path original
  path="$1"
  original="$(cat "$path")"
  if npx prettier -u -w "$path" 1>/dev/null 2>&1; then
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
  npx prettier --check "$path"
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
  if black "$path"; then
    echo "↳ black        ok"
  else
    echo "↳ black        wrote"
  fi
}

check_py() {
  local path
  path="$1"
  echo "# black $path"
  black --check "$path"
}

fix() {
  local path
  path="$1"
  echo "# $path"
  if [ "$FULLY_STAGED_ONLY" = "yes" ]; then
    if git diff --name-only | grep -qF "$path"; then
      # path has unstaged changes, so don't modify it
      echo "↳ unstaged changes, skipping"
      echo
      return
    fi
  fi
  case "$path" in
    *.md | *.yml) fix_prettier "$path" ;;
    *.bats) fix_bats "$path" ;;
    *.sh | *.bash) fix_bash "$path" ;;
    *.py) fix_py "$path" ;;
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
    *.md | *.yml) check_prettier "$path" ;;
    *.bats) check_bats "$path" ;;
    *.sh | *.bash) check_bash "$path" ;;
    *.py) check_py "$path" ;;
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
