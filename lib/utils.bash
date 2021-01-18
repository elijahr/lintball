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
BUNDLE_GEMFILE="${LINTBALL_DIR}/Gemfile"
export BUNDLE_GEMFILE

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
    echo "${LINTBALL_DIR}/python-env/bin/autopep8 \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOPEP8}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/python-env/bin/autopep8 \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOPEP8}") \
      '$path'"
  fi
}

cmd_docformatter() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/python-env/bin/docformatter \
      $(eval echo "${LINTBALL__WRITE_ARGS__DOCFORMATTER}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/python-env/bin/docformatter \
      $(eval echo "${LINTBALL__CHECK_ARGS__DOCFORMATTER}") \
      '$path'"
  fi
}

cmd_isort() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/python-env/bin/isort \
      $(eval echo "${LINTBALL__WRITE_ARGS__ISORT}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/python-env/bin/isort \
      $(eval echo "${LINTBALL__CHECK_ARGS__ISORT}") \
      '$path'"
  fi
}

cmd_autoflake() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/python-env/bin/autoflake \
      $(eval echo "${LINTBALL__WRITE_ARGS__AUTOFLAKE}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/python-env/bin/autoflake \
      $(eval echo "${LINTBALL__CHECK_ARGS__AUTOFLAKE}") \
      '$path'"
  fi
}

cmd_black() {
  local write path
  write="$1"
  path="$2"
  if [ "$write" = "yes" ]; then
    echo "${LINTBALL_DIR}/python-env/bin/black \
      $(eval echo "${LINTBALL__WRITE_ARGS__BLACK}") \
      '$path'"
  else
    echo "${LINTBALL_DIR}/python-env/bin/black \
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

usage() {
  cat <<EOF

lintball: keep your project tidy with one command.

Linters/formatters used:

JSON,
Markdown, HTML, CSS, SASS.......prettier
JavaScript, TypeScript, JSX.....prettier-eslint
YAML............................prettier, yamllint
sh, bash, dash, ksh, mksh.......shellcheck, shfmt
Bats tests......................shfmt
Python..........................autoflake, autopep8, black, docformatter, isort
Cython..........................autoflake, autopep8, docformatter
Nim.............................nimpretty
Ruby............................rubocop


Usage: lintball [options] [command] [command options]

Options:

  -h | --help
      Show this help message & exit.

  -v | --version
      Print version & exit.

  -c | --config path
      Use the .lintballrc.json config file at path.

Commands:

  check [path ...]
      Check for and display linter issues recursively in paths or working dir.

  fix [path ...]
      Auto fix all fixable issues recursively in paths or working dir.

  list [path ...]
      List files which lintball recognizes for checking or fixing.

  githooks [options] [path]
      Install lintball githooks in the git repo at path or working dir.

      Options:

        --yes
          If destination exists, overwrite.

        --no
          If destination exists, exit without copying.

  lintballrc [options] [path]
      Place a default .lintballrc.json configuration file in path or working dir.

      Options:

        --yes
          If destination exists, overwrite.

        --no
          If destination exists, exit without copying.


https://github.com/elijahr/lintball

EOF
}

confirm_copy() {
  local src dest
  src="$1"
  dest="$2"
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
  cp -Rf "$src" "$dest"
  echo "Copied ${src//${HOME}/"~"} → ${dest//${HOME}/"~"}"
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

lintball_githooks() {
  local git_dir hooks_path hook dest status remove_start remove_end tmp
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
    confirm_copy "$hook" "$dest" || status=$?
    if [ "$status" -gt 0 ]; then
      exit $status
    fi
    # strip lintball-repo specific section
    remove_start="$(grep -nF "# >>> remove" "$dest" | sed 's/:.*//')"
    remove_end="$(grep -nF "# <<< remove" "$dest" | sed 's/:.*//')"
    tmp="$(mktemp)"
    head -n "$((remove_start - 1))" "$dest" >"$tmp"
    tail -n +"$((remove_end + 1))" "$dest" >>"$tmp"
    mv "$tmp" "$dest"
  done
  git --git-dir="$git_dir" config --local core.hooksPath "$hooks_path"
  echo
  echo "Set git hooks path → $hooks_path"
  echo
  exit 0
}

lintball_lintballrc() {
  confirm_copy "${LINTBALL_DIR}/configs/lintballrc.json" "${1}/.lintballrc.json" || exit $?
}

lintball_check_or_fix() {
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

lintball_check() {
  lintball_check_or_fix "no" "$@"
}

lintball_fix() {
  lintball_check_or_fix "yes" "$@"
}

lintball_list() {
  local line
  eval "$(cmd_find "$@")" | sort -n | while read -r line; do
    if assert_handled_path "$line"; then
      line="$(normalize_path "$line")"
      echo "$line"
    fi
  done
}

parse_args() {
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
      parse_subcommand_args "$@"
      ;;
    -*)
      echo -e "Unknown switch $1"
      usage
      exit 1
      ;;
    *)
      LINTBALL_CONFIG="$(find_config)"
      export LINTBALL_CONFIG
      parse_subcommand_args "$@"
      ;;
  esac
}

parse_subcommand_args() {
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
    echo "# Using config file ${LINTBALL_CONFIG}"
    echo
    load_config "$LINTBALL_CONFIG" || exit 1
  fi

  case "$1" in
    check | fix | list)
      command="lintball_$1"
      shift
      eval "$command" "$@"
      ;;
    githooks | lintballrc)
      command="lintball_${1//-/_}"
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
