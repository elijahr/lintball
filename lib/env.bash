# shellcheck disable=SC2034

# Expected lintballrc_version in config files
LINTBALLRC_VERSION="2"
export LINTBALLRC_VERSION

# Global lintball config - modified by config files
declare -a LINTBALL_CHECK_ARGS_AUTOFLAKE=()
declare -a LINTBALL_CHECK_ARGS_AUTOPEP8=()
declare -a LINTBALL_CHECK_ARGS_BLACK=()
declare -a LINTBALL_CHECK_ARGS_CLIPPY=()
declare -a LINTBALL_CHECK_ARGS_DOCFORMATTER=()
declare -a LINTBALL_CHECK_ARGS_ISORT=()
declare -a LINTBALL_CHECK_ARGS_NIMPRETTY=()
declare -a LINTBALL_CHECK_ARGS_PRETTIER=()
declare -a LINTBALL_CHECK_ARGS_PRETTIER_ESLINT=()
declare -a LINTBALL_CHECK_ARGS_PYLINT=()
declare -a LINTBALL_CHECK_ARGS_RUBOCOP=()
declare -a LINTBALL_CHECK_ARGS_SHELLCHECK=()
declare -a LINTBALL_CHECK_ARGS_SHFMT=()
declare -a LINTBALL_CHECK_ARGS_STYLUA=()
declare -a LINTBALL_CHECK_ARGS_UNCRUSTIFY=()
declare -a LINTBALL_CHECK_ARGS_YAMLLINT=()

declare -a LINTBALL_WRITE_ARGS_AUTOFLAKE=()
declare -a LINTBALL_WRITE_ARGS_AUTOPEP8=()
declare -a LINTBALL_WRITE_ARGS_BLACK=()
declare -a LINTBALL_WRITE_ARGS_CLIPPY=()
declare -a LINTBALL_WRITE_ARGS_DOCFORMATTER=()
declare -a LINTBALL_WRITE_ARGS_ISORT=()
declare -a LINTBALL_WRITE_ARGS_NIMPRETTY=()
declare -a LINTBALL_WRITE_ARGS_PRETTIER=()
declare -a LINTBALL_WRITE_ARGS_PRETTIER_ESLINT=()
declare -a LINTBALL_WRITE_ARGS_PYLINT=()
declare -a LINTBALL_WRITE_ARGS_RUBOCOP=()
declare -a LINTBALL_WRITE_ARGS_SHELLCHECK=()
declare -a LINTBALL_WRITE_ARGS_SHFMT=()
declare -a LINTBALL_WRITE_ARGS_STYLUA=()
declare -a LINTBALL_WRITE_ARGS_UNCRUSTIFY=()
declare -a LINTBALL_WRITE_ARGS_YAMLLINT=()

declare -a LINTBALL_IGNORE_GLOBS=()

declare -a LINTBALL_ALL_TOOLS=(
  autoflake autopep8 black clippy docformatter isort nimpretty
  prettier prettier-eslint pylint rubocop shellcheck shfmt stylua
  uncrustify yamllint)

# ASDF config
# Specific tool versions are configured in lib/installers/*.bash
ASDF_VERSION=v0.10.2
export ASDF_VERSION
ASDF_CONFIG_FILE="${LINTBALL_DIR}/configs/asdfrc"
export ASDF_CONFIG_FILE
ASDF_DEFAULT_TOOL_VERSIONS_FILENAME="no-tool-versions"
export ASDF_DEFAULT_TOOL_VERSIONS_FILENAME
ASDF_DIR="${LINTBALL_DIR}/tools/asdf"
export ASDF_DIR
ASDF_DATA_DIR="${LINTBALL_DIR}/tools/asdf"
export ASDF_DATA_DIR

# Used by some tools to determine whether to install binaries or compile source
LIBC_TYPE="$(if command -v clang 2>&1 >/dev/null; then
  echo "clang"
elif ldd /bin/ls | grep musl 2>&1 >/dev/null; then
  echo "musl"
else
  echo "gnu"
fi)"
export LIBC_TYPE

# Setup PATH to find installed tools
PATH="${LINTBALL_DIR}/tools/node_modules/.bin:${PATH}"
PATH="${LINTBALL_DIR}/tools/asdf/shims:${PATH}"
PATH="${LINTBALL_DIR}/tools/asdf/bin:${PATH}"
PATH="${LINTBALL_DIR}/tools/bin:${PATH}"
export PATH
