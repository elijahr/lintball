DOTS="..................................."

run_tool() {
  local tool mode path lang use status original cmd stdout stderr
  tool="$1"
  mode="$2"
  path="$3"
  lang="${4:-}"

  offset="${#tool}"
  use="LINTBALL__USE__$(echo "${tool//-/_}" | tr '[:lower:]' '[:upper:]')"
  if [ "${!use}" = "false" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "disabled"
    return 0
  fi

  status=0
  original="$(cat "$path")"
  stdout="$(mktemp)"
  stderr="$(mktemp)"
  cmd="$(cmd_"${tool//-/_}" "$mode" "$path" "$lang")"

  set -f
  eval "$cmd" 1>"$stdout" 2>"$stderr" || status=$?
  set +f
  if [ "$(cat "$path")" = "$original" ]; then
    if [ "$status" -gt 0 ] || {
      [ "$mode" = "mode=write" ] &&
        [ "$(head -n1 "$stdout" | head -c4)" = "--- " ] &&
        [ "$(head -n2 "$stdout" | tail -n 1 | head -c4)" = "+++ " ]
    }; then
      # Some error message
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
      cat "$stdout" 2>/dev/null
      cat "$stderr" 1>&2 2>/dev/null
      status=1
    else
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "ok"
    fi
  else
    status=0
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "wrote"
  fi
  rm "$stdout"
  rm "$stderr"
  return $status
}

run_tool_nimpretty() {
  local mode path tool offset use args tmp patch stdout stderr status
  mode="$1"
  path="$2"

  tool="nimpretty"
  offset="${#tool}"

  if [ "$LINTBALL__USE__NIMPRETTY" = "false" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "disabled"
    return 0
  fi

  if [ "$mode" = "mode=write" ]; then
    args="${LINTBALL__WRITE_ARGS__NIMPRETTY}"
  else
    args="${LINTBALL__CHECK_ARGS__NIMPRETTY}"
  fi

  if [ -z "$(which nimpretty)" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "😵 not installed"
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
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "ok"
    else
      patch="$(diff -u "$path" "$tmp")"
      if [ -n "$patch" ]; then
        if [ "$mode" = "mode=write" ]; then
          cat "$tmp" >"$path"
          printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "wrote"
        else
          printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
          echo "$patch"
          status=1
        fi
      else
        printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
        cat "$stdout" 2>/dev/null
        cat "$stderr" 1>&2 2>/dev/null
      fi
    fi
  else
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
    cat "$stdout" 2>/dev/null
    cat "$stderr" 1>&2 2>/dev/null
  fi
  rm "$tmp"
  rm "$stdout"
  rm "$stderr"
  return $status
}

run_tool_prettier_eslint() {
  local mode path tool offset cmd stdout stderr status
  mode="$1"
  path="$2"

  tool="prettier-eslint"
  offset="${#tool}"

  if [ "$LINTBALL__USE__PRETTIER_ESLINT" = "false" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "disabled"
    return 0
  fi

  if [ "$mode" = "mode=write" ]; then
    cmd="npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__WRITE_ARGS__PRETTIER_ESLINT}") \
      '${PWD}/${path}'"
  else
    cmd="npm \
      --prefix='$LINTBALL_DIR' \
      run \
      prettier-eslint \
      --path='$(pwd)' \
      -- \
      $(eval echo "${LINTBALL__CHECK_ARGS__PRETTIER_ESLINT}") \
      '${PWD}/${path}'"
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
    if [[ "$(cat "$stderr")" =~ unchanged ]]; then
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "ok"
    elif [ "$mode" = "mode=write" ] &&
      [[ "$(cat "$stderr")" =~ success\ formatting ]]; then
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "wrote"
    else
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
      cat "$stdout" 1>&2 2>/dev/null
      cat "$stderr" 1>&2 2>/dev/null
      status=1
    fi
  else
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
    cat "$stdout" 2>/dev/null
    cat "$stderr" 1>&2 2>/dev/null
  fi
  rm "$stdout"
  rm "$stderr"
  return $status
}

run_tool_shellcheck() {
  local mode path args lang tool offset stdout stderr status color
  mode="$1"
  path="$2"
  lang="$3"

  tool="shellcheck"
  offset="${#tool}"

  if [ "$LINTBALL__USE__SHELLCHECK" = "false" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "disabled"
    return 0
  fi

  if [ "$mode" = "mode=write" ]; then
    args="${LINTBALL__WRITE_ARGS__SHELLCHECK}"
  else
    args="${LINTBALL__CHECK_ARGS__SHELLCHECK}"
  fi

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
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "ok"
  else
    # stdout contains the tool results
    # stderr contains an error message
    if [ "$mode" = "mode=write" ] && [ -n "$(cat "$stdout" 2>/dev/null)" ]; then
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
        printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "wrote"
        status=0
      else
        if [ -n "$(cat "$patcherr")" ]; then
          # not patchable, show output from initial shellcheck run
          printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
          cat "$stdout"
        else
          printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "unknown error"
        fi
      fi
    else
      # not patchable, show error
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
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

run_tool_uncrustify() {
  local mode path lang tool offset args patch stdout stderr status
  mode="$1"
  path="$2"
  lang="$3"

  tool="uncrustify"
  offset="${#tool}"

  if [ "$LINTBALL__USE__UNCRUSTIFY" = "false" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "disabled"
    return 0
  fi

  if [ "$mode" = "mode=write" ]; then
    args="${LINTBALL__WRITE_ARGS__UNCRUSTIFY}"
  else
    args="${LINTBALL__CHECK_ARGS__UNCRUSTIFY}"
  fi

  if [ -z "$(which uncrustify)" ]; then
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "😵 not installed"
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
      printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "ok"
    else
      patch="$(diff -u "$path" "$stdout")"
      if [ -n "$patch" ]; then
        if [ "$mode" = "mode=write" ]; then
          cat "$stdout" >"$path"
          printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "wrote"
        else
          printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
          echo "$patch"
          status=1
        fi
      else
        printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
        cat "$stdout" 2>/dev/null
        cat "$stderr" 1>&2 2>/dev/null
      fi
    fi
  else
    printf "%s%s%s\n" "↳ ${tool}" "${DOTS:offset}" "⚠️   see below"
    cat "$stderr" 1>&2 2>/dev/null
  fi
  rm "$stdout"
  rm "$stderr"
  return $status
}
