#!/usr/bin/env bash

LINTBALL_DIR="${LINTBALL_DIR:-"${PWD}/lintball"}"
export LINTBALL_DIR

IGNORE_GLOBS=()

# For rubocop
BUNDLE_GEMFILE="${LINTBALL_DIR}/tools/Gemfile"
export BUNDLE_GEMFILE

# shellcheck source=SCRIPTDIR/cmds.bash
source "${LINTBALL_DIR}/lib/cmds.bash"

# shellcheck source=SCRIPTDIR/install.bash
source "${LINTBALL_DIR}/lib/install.bash"

# shellcheck source=SCRIPTDIR/tools.bash
source "${LINTBALL_DIR}/lib/tools.bash"

cli_entrypoint() {
  local config mode commit paths fn path answer all
  config=""

  # Parse base options
  while true; do
    case "${1:-}" in
      -h | --help)
        usage
        support_table
        documentation_link
        return 0
        ;;
      -v | --version)
        bash "${LINTBALL_DIR}/lib/jwalk/lib/jwalk.sh" <"${LINTBALL_DIR}/package.json" | grep "^version" | awk '{ print $3 }'
        return 0
        ;;
      -c | --config)
        shift
        config="$1"
        shift
        ;;
      -*)
        echo >&2
        echo "Unknown option $1" >&2
        usage >&2
        documentation_link >&2
        return 1
        ;;
      *)
        break
        ;;
    esac
  done
  if [ -z "$config" ]; then
    config="$(config_find)"
  fi
  answer=""
  all="all=no"

  # Load default configs
  config_load "${LINTBALL_DIR}/configs/lintballrc-defaults.json"
  config_load "${LINTBALL_DIR}/configs/lintballrc-ignores.json"

  if [ -n "$config" ]; then
    echo
    echo "# lintball: using config file ${config}"
    echo
    config_load "$config" || return 1
  fi

  # Parse subcommand
  case "${1:-}" in
    check | fix)
      case "$1" in
        check) mode="mode=check" ;;
        fix) mode="mode=write" ;;
      esac
      shift
      case "${1:-}" in
        -s | --since)
          shift
          commit="$1"
          shift
          paths="$(get_paths_changed_since_commit "$commit")"
          if [ -z "$paths" ]; then
            return 0
          fi
          ;;
        *) paths="$(
          for path in "$@"; do
            echo "$path"
          done
        )" ;;
      esac
      subcommand_process_files "$mode" "gitadd=no" "$paths"
      return $?
      ;;
    pre-commit)
      if git rebase --show-current-patch 2>/dev/null; then
        echo "Rebase in progress, not running lintball pre-commit hook."
        echo
        return 0
      fi
      shift
      paths="$(get_fully_staged_paths)"
      if [ -z "$paths" ]; then
        return 0
      fi
      subcommand_process_files "mode=write" "gitadd=yes" "$paths"
      return $?
      ;;
    install-githooks | install-lintballrc | install-tools)
      fn="subcommand_${1//-/_}"
      shift
      while true; do
        case "${1:-}" in
          -y | --yes)
            answer="answer=yes"
            shift
            ;;
          -n | --no)
            answer="answer=no"
            shift
            ;;
          -a | --all)
            all="all=yes"
            shift
            ;;
          -p | --path)
            shift
            path="$1"
            shift
            ;;
          -*)
            echo >&2
            echo "Unknown option $1" >&2
            usage >&2
            documentation_link >&2
            echo >&2
            return 1
            ;;
          *)
            break
            ;;
        esac
      done
      path="${path:-$PWD}"
      if [ "$fn" = "subcommand_install_tools" ]; then
        # Pass extensions to install_tools
        "$fn" "$path" "$answer" "$all" "$@"
        return $?
      else
        if [ "$#" -gt 0 ]; then
          echo "$fn: unexpected argument '$1'" >&2
          echo >&2
          return 1
        fi
        "$fn" "$path" "$answer"
        return $?
      fi
      ;;
    *)
      if [ -z "${1:-}" ]; then
        echo "missing subcommand" >&2
      else
        echo "unknown subcommand '$1'" >&2
      fi
      usage >&2
      documentation_link >&2
      return 1
      ;;
  esac
}

cmd_find() {
  local line
  printf 'find '
  if [ "${*// /}" = "" ]; then
    # all args were whitespace only, so default to current dir
    printf '"." '
  else
    echo "$@" | while read -r line; do
      if [ -n "${line// /}" ]; then
        printf '"%s" ' "$(normalize_path "$line")"
      fi
    done
  fi

  printf '"-type" "f" '

  for ignore in "${IGNORE_GLOBS[@]}"; do
    printf '"-a" "(" "-not" "-path" "%s" ")" ' "$ignore"
  done

  printf '"-print" '
}

config_find() {
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

config_load() {
  local path name value line
  path="$(normalize_path "$1")"

  if [ ! -f "$path" ]; then
    echo "No config file at ${path}" >&2
    return 1
  fi

  # Clear the ignores array
  IGNORE_GLOBS=()

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
        IGNORE_GLOBS+=("$(echo "$line" | awk '{ print $4 }')")
        ;;
    esac
  done <<<"$(bash "${LINTBALL_DIR}/lib/jwalk/lib/jwalk.sh" <"$path")"
}

confirm_copy() {
  local src dest answer symlink
  src="$1"
  dest="$2"
  answer="$3"
  symlink="$4"
  if [ -d "$src" ] || [ -d "$dest" ]; then
    echo >&2
    echo "Source and destination must be file paths, not directories." >&2
    echo >&2
    return 1
  fi
  if [ -f "$dest" ]; then
    if [ -z "$answer" ]; then
      read -rp "${dest//${HOME}/"~"} exists. Replace? [y/N] " answer
    fi
    case "$answer" in
      [yY]*) ;;
      *)
        echo >&2
        echo "File exists, cancelled: $dest" >&2
        echo >&2
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

documentation_link() {
  echo "Additional documentation can be found in ${LINTBALL_DIR}/README.md"
  echo "or at https://github.com/elijahr/lintball"
  echo
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

get_fully_staged_paths() {
  local staged line
  staged="$(git diff --name-only --cached | sort)"
  echo "$staged" | while read -r line; do
    # shellcheck disable=SC2143
    if [ -z "$(git diff --name-only | grep -F "$line")" ]; then
      if [ -f "$line" ]; then
        # path exists, is staged and has no unstaged changes
        echo "$line"
      fi
    fi
  done
}

get_installer_for_tool() {
  local tool
  tool="$1"
  case "$tool" in
    autoflake | autopep8 | black | docformatter | isort | yamllint)
      echo "install_pip_requirements"
      ;;
    clippy) echo "install_clippy" ;;
    nimpretty) echo "validate_nimpretty" ;;
    prettier | prettier-eslint)
      return
      ;; # no-op, these are installed by npm
    rubocop) echo "install_bundler_requirements" ;;
    shellcheck | shfmt) echo "install_shell_tools" ;;
    stylua) echo "install_stylua" ;;
    uncrustify) echo "install_uncrustify" ;;
  esac
}

get_lang_shellcheck() {
  local extension
  extension="$1"
  case "$extension" in
    mksh) echo "ksh" ;;
    *) echo "$extension" ;;
  esac
}

get_lang_shfmt() {
  local extension
  extension="$1"
  case "$extension" in
    ksh) echo "mksh" ;;
    sh | dash) echo "posix" ;;
    *) echo "$extension" ;;
  esac
}

get_lang_uncrustify() {
  local extension
  extension="$1"
  case "$extension" in
    c | h) echo "c" ;;
    cs | cpp | d | hpp) echo "cpp" ;;
    m | mm | M) echo "objc" ;;
  esac
}

get_paths_changed_since_commit() {
  local commit
  commit="$1"
  (
    git diff --name-only "$commit"
    git ls-files . --exclude-standard --others
  ) | sort | uniq | xargs -I{} sh -c "test -f '{}' && echo '{}'"
}

get_shebang() {
  local path
  path="$1"
  (
    LC_CTYPE="C"
    export LC_CTYPE
    if [ "$(tr '\0' ' ' <"$path" | head -c2 2>/dev/null)" = "#!" ]; then
      head -n1 "$path"
    fi
  )
}

get_tools_for_file() {
  local path extension
  mode="$1"
  path="$1"

  path="$(normalize_path "$path")"
  extension="$(normalize_extension "$path")"

  case "$extension" in
    css | graphql | html | jade | java | json | md | pug | scss | xml)
      echo "prettier"
      ;;
    bash | bats | dash | ksh | mksh | sh)
      echo "shfmt"
      echo "shellcheck"
      ;;
    c | cpp | cs | d | h | hpp | m | mm | M)
      echo "uncrustify"
      ;;
    js | jsx | ts | tsx)
      echo "prettier-eslint"
      ;;
    lua)
      echo "stylua"
      ;;
    nim)
      echo "nimpretty"
      ;;
    py)
      echo "docformatter"
      echo "autopep8"
      echo "autoflake"
      echo "isort"
      echo "black"
      ;;
    pyx | pxd | pxi)
      echo "docformatter"
      echo "autopep8"
      echo "autoflake"
      ;;
    rb)
      echo "rubocop"
      echo "prettier"
      ;;
    rs)
      echo "clippy"
      ;;
    toml)
      if [ "$(basename "$path")" = "Cargo.toml" ]; then
        # Special case for Rust package; clippy analyzes an entire crate, not a
        # single path, so when a Cargo.toml is encountered, use clippy.
        echo "clippy"
      fi
      ;;
    yml)
      echo "prettier"
      echo "yamllint"
      ;;
  esac
}

normalize_extension() {
  local path lang filename extension
  path="$1"

  # Check for `# lintball lang=foo` directives
  if [ -f "$path" ]; then
    lang="$(grep '^# lintball lang=' "$path" | sed 's/^# lintball lang=//' | tr '[:upper:]' '[:lower:]')"
  else
    lang=""
  fi

  case "$lang" in
    cython) extension="pyx" ;;
    javascript) extension="js" ;;
    markdown) extension="md" ;;
    python) extension="py" ;;
    ruby) extension="rb" ;;
    typescript) extension="ts" ;;
    yaml) extension="yml" ;;
    *)
      if [ -n "$lang" ]; then
        extension="$lang"
      else
        filename="$(basename "$path")"
        if [ "$filename" = "Gemfile" ]; then
          extension="rb"
        else
          extension="${filename##*.}"
        fi
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
      # Inspect shebang to get actual shell interpreter
      case "$(get_shebang "$path")" in
        *bash) echo "bash" ;;
        *dash) echo "dash" ;;
        *mksh) echo "mksh" ;;
        *ksh) echo "ksh" ;;
        *) echo "sh" ;;
      esac
      ;;
    yaml) echo "yml" ;;
    *)
      # File has no extension, inspect shebang to get interpreter
      case "$(get_shebang "$path")" in
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

# shellcheck disable=SC2120
parse_version() {
  local text line
  text="$1"
  echo "$text" |
    grep '[0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}' |
    head -n 1 |
    sed 's/.*\([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\).*/\1/'
}

process_file() {
  local path mode gitadd status extension tools tool
  path="$1"
  mode="$2"
  gitadd="$3"

  status=0
  path="$(normalize_path "$path")"
  tools="$(get_tools_for_file "$path")"
  if [ -z "$tools" ]; then
    return 0
  fi

  extension="$(normalize_extension "$path")"
  echo "# $path"
  while read -r tool; do
    {
      case "$tool" in
        nimpretty) run_tool_nimpretty "$mode" "$path" ;;
        prettier-eslint) run_tool_prettier_eslint "$mode" "$path" ;;
        shellcheck) run_tool_shellcheck "$mode" "$path" "$(get_lang_shellcheck "$extension")" ;;
        shfmt) run_tool "shfmt" "$mode" "$path" "$(get_lang_shfmt "$extension")" ;;
        uncrustify) run_tool_uncrustify "$mode" "$path" "$(get_lang_uncrustify "$extension")" ;;
        *) run_tool "$tool" "$mode" "$path" ;;
      esac
    } || status=$?
  done <<<"$tools"
  echo

  if [ "$status" -eq 0 ] && [ "$gitadd" = "gitadd=yes" ]; then
    git add "$path"
  fi

  return $status
}

subcommand_install_githooks() {
  local path answer git_dir hooks_path hook dest status
  path="$1"
  answer="$2"

  git_dir="$(find_git_dir "$path" || true)"
  if [ -z "$git_dir" ]; then
    echo >&2
    echo "Could not find a .git directory at or above $path" >&2
    echo >&2
    return 1
  fi

  hooks_path="$(git --git-dir="$git_dir" config --local core.hooksPath || true)"
  if [ -z "$hooks_path" ]; then
    hooks_path="${1}/.githooks"
  fi
  for hook in "${LINTBALL_DIR}/githooks/"*; do
    status=0
    dest="${hooks_path}/$(basename "$hook")"
    confirm_copy "$hook" "$dest" "$answer" "symlink=yes" || status=$?
    if [ "$status" -gt 0 ]; then
      return $status
    fi
  done
  git --git-dir="$git_dir" config --local core.hooksPath "$hooks_path"
  echo
  echo "Set git hooks path → $hooks_path"
  echo
  return 0
}

subcommand_install_lintballrc() {
  local path answer
  path="$1"
  answer="$2"
  confirm_copy \
    "${LINTBALL_DIR}/configs/lintballrc-ignores.json" \
    "${path}/.lintballrc.json" \
    "$answer" \
    "symlink=no" || return $?
}

subcommand_install_tools() {
  local path answer all extension tools tool file installers installer
  path="$1"
  answer="$2"
  all="$3"
  shift
  shift
  shift

  if [ "$all" = "all=yes" ]; then
    # install everything
    tools="$(
      cat <<EOF
autoflake
autopep8
black
clippy
docformatter
isort
nimpretty
prettier
prettier-eslint
rubocop
shellcheck
shfmt
stylua
uncrustify
yamllint
EOF
    )"
  elif [ "$#" -gt 0 ]; then
    # extensions provided by user on command line
    tools="$(
      for extension in "$@"; do
        get_tools_for_file "_.$extension"
      done
    )"
  else
    # examine path to find tools to install
    tools="$(
      eval "$(cmd_find "$path")" | while read -r file; do
        get_tools_for_file "$file"
      done
    )"
  fi

  installers="$(
    echo "$tools" | while read -r tool; do
      get_installer_for_tool "$tool"
    done
  )"

  echo "$installers" | sort | uniq | while read -r installer; do
    if [ -n "$installer" ]; then
      "$installer" "$answer"
    fi
  done
}

subcommand_process_files() {
  local mode gitadd err path status
  mode="$1"
  gitadd="$2"
  shift
  shift
  err="$(mktemp -d)/err"
  eval "$(cmd_find "$@")" | while read -r path; do
    process_file "$path" "$mode" "$gitadd" || touch "$err"
  done
  status=0
  [ ! -f "$err" ] || status=1
  rm -rf "$(dirname "$err")"
  return "$status"
}

support_table() {
  cat <<EOF
Supported tools:
  | Language     |                                      Tools used |
  | :----------- | ----------------------------------------------: |
  | bash         |                               shellcheck, shfmt |
  | bats         |                               shellcheck, shfmt |
  | C            |                                      uncrustify |
  | C#           |                                      uncrustify |
  | C++          |                                      uncrustify |
  | CSS          |                                        prettier |
  | Cython       |               autoflake, autopep8, docformatter |
  | D            |                                      uncrustify |
  | dash         |                               shellcheck, shfmt |
  | GraphQL      |                                        prettier |
  | HTML         |                                        prettier |
  | Java         |                                   prettier-java |
  | JavaScript   |                                 prettier-eslint |
  | JSON         |                                        prettier |
  | JSX          |                                 prettier-eslint |
  | ksh          |                               shellcheck, shfmt |
  | Lua          |                                          StyLua |
  | Luau         |                                          StyLua |
  | Markdown     |                                        prettier |
  | mksh         |                               shellcheck, shfmt |
  | Nim          |                                       nimpretty |
  | Objective-C  |                                      uncrustify |
  | package.json |                           prettier-package-json |
  | pug          |                             prettier/plugin-pug |
  | Python       | autoflake, autopep8, black, docformatter, isort |
  | Ruby         |                  @prettier/plugin-ruby, rubocop |
  | Rust         |                                          clippy |
  | SASS         |                                        prettier |
  | sh           |                               shellcheck, shfmt |
  | TSX          |                                 prettier-eslint |
  | TypeScript   |                                 prettier-eslint |
  | XML          |                             prettier/plugin-xml |
  | YAML         |                              prettier, yamllint |

Detection methods:
  | Language     |                                           Detection |
  | :----------- | --------------------------------------------------: |
  | bash         |                         *.bash, #!/usr/bin/env bash |
  | bats         |                         *.bats, #!/usr/bin/env bats |
  | C            |                                            *.c, *.h |
  | C#           |                                                *.cs |
  | C++          |                                        *.cpp, *.hpp |
  | CSS          |                                               *.css |
  | Cython       |                                 *.pyx, *.pxd, *.pxi |
  | D            |                                                 *.d |
  | dash         |                         *.dash, #!/usr/bin/env dash |
  | GraphQL      |                                           *.graphql |
  | HTML         |                                              *.html |
  | Java         |                                              *.java |
  | JavaScript   |      *.js, #!/usr/bin/env node, #!/usr/bin/env deno |
  | JSON         |                                              *.json |
  | JSX          |                                               *.jsx |
  | ksh          |                           *.ksh, #!/usr/bin/env ksh |
  | Lua          |                                               *.lua |
  | Luau         |                                              *.luau |
  | Markdown     |                                                *.md |
  | mksh         |                         *.mksh, #!/usr/bin/env mksh |
  | Nim          |                                               *.nim |
  | Objective-C  |                                      *.m, *.mm, *.M |
  | package.json |                                        package.json |
  | pug          |                                               *.pug |
  | Python       | *.py, #!/usr/bin/env python, #!/usr/bin/env python3 |
  | Ruby         |                  *.rb, Gemfile, #!/usr/bin/env ruby |
  | Rust         |                                          Cargo.toml |
  | SASS         |                                              *.scss |
  | sh           |                                     *.sh, #!/bin/sh |
  | TSX          |                                               *.tsx |
  | TypeScript   |                                                *.ts |
  | XML          |                                               *.xml |
  | YAML         |                                       *.yml, *.yaml |

EOF
}

usage() {
  cat <<EOF

█   █ █▄ █ ▀█▀ ██▄ ▄▀▄ █   █
█▄▄ █ █ ▀█  █  █▄█ █▀█ █▄▄ █▄▄
keep your entire project tidy with one command.

Usage:
  lintball [-h | -v]
  lintball [-c <path>] check [--since <commit>] [paths …]
  lintball [-c <path>] fix [--since <commit>] [paths …]
  lintball [-c <path>] install-githooks [-y | -n] [-p <path>]
  lintball [-c <path>] install-lintballrc [-y | -n] [-p <path>]
  lintball [-c <path>] install-tools [-y | -n] [-a] [-p <path>] [ext …]
  lintball [-c <path>] pre-commit

Options:
  -h, --help                Show this help message & exit.
  -v, --version             Print version & exit.
  -c, --config <path>       Use the config file at <path>.

Subcommands:
  check [paths …]           Recursively check for issues.
                              Exit 1 if any issues.
    -s, --since <commit>    Check only files changed since <commit>. This
                            includes both committed and uncommitted changes.
                            <commit> may be a commit hash or a committish, such
                            as HEAD~1 or master.
  fix [paths …]             Recursively fix issues.
                              Exit 1 if unfixable issues.
    -s, --since <commit>    Fix only files changed since <commit>. This
                            includes both committed and uncommitted changes.
                            <commit> may be a commit hash or a committish, such
                            as HEAD~1 or master.
  install-githooks          Install lintball githooks in a git repository.
    -p, --path <path>       Git repo path.
                              Default: working directory.
    -y, --yes               Skip prompt & replace repo's githooks.
    -n, --no                Skip prompt & exit 1 if repo already has githooks.
  install-lintballrc        Create a default .lintballrc.json config file.
    -p, --path <path>       Where to install the config file.
                              Default: working directory
    -y, --yes               Skip prompt & replace existing .lintballrc.json.
    -n, --no                Skip prompt & exit 1 if .lintballrc.json exists.
  install-tools [ext …]     Install tools for fixing files having extensions
                            [ext]. If no [ext] are provided, lintball will
                            autodetect which tools to install based on files in
                            <path>.
    -p, --path <path>       The path to search for file types.
                              Default: working directory
    -y, --yes               Skip prompt & install missing dependencies.
    -a, --all               Install *all* tools.
  pre-commit                Recursively fix issues on files that are fully
                            staged for commit. Recursively check for issues on
                            files that are partially staged for commit.
                              Exit 1 if unfixable issues on fully staged files.
                              Exit 1 if any issues on partially staged files.

Examples:
  \$ lintball check                       # Check working directory for issues.
  \$ lintball check --since HEAD~1        # Check working directory for issues
                                         # in all files changes since the commit
                                         # before last.
  \$ lintball check foo                   # Check the foo directory for issues.
  \$ lintball check foo.py                # Check the foo.py file for issues.
  \$ lintball fix                         # Fix issues in the working directory.
  \$ lintball -c foo/.lintballrc.json fix # Fix issues in the working directory
                                         # using the specified config.
  \$ lintball fix foo                     # Fix issues in the foo directory.
  \$ lintball fix foo.py                  # Fix issues in the foo.py file.
  \$ lintball install-githooks -p foo     # Install githooks in directory foo.
  \$ lintball install-githooks --yes      # Install a githooks config, replacing
                                         # any existing githooks config.
  \$ lintball install-lintballrc          # Install a default .lintballrc.json
                                         # in the working directory.
  \$ lintball install-lintballrc -p foo   # Install default .lintballrc.json in
                                         # directory foo.
  \$ lintball install-tools --yes         # Autodetect tools for working
                                         # directory and install them, no
                                         # prompt.
  \$ lintball install-tools -p foo        # Autodetect tools for directory foo
                                         # and install them.
  \$ lintball install-tools --all         # Install all tools.
  \$ lintball install-tools py java yaml  # Install tools for checking Python,
                                         # JavaScript, & YAML.

EOF
}
