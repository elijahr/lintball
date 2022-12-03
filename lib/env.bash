set -ueo pipefail
shopt -s nullglob

LIBC_TYPE="$(if command -v clang 2>&1 >/dev/null; then
  echo "clang"
elif ldd /bin/ls | grep musl 2>&1 >/dev/null; then
  echo "musl"
else
  echo "gnu"
fi)"
export LIBC_TYPE

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
PATH="${LINTBALL_DIR}/tools/node_modules/.bin:${PATH}"
PATH="${LINTBALL_DIR}/tools/asdf/shims:${PATH}"
PATH="${LINTBALL_DIR}/tools/asdf/bin:${PATH}"
PATH="${LINTBALL_DIR}/tools/bin:${PATH}"
export PATH
