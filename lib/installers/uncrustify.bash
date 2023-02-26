# shellcheck disable=SC2154

install_uncrustify() {
  local old status
  status=0
  # uncrustify build depends on python 3
  install_python || return $?
  if [[ ! -f "${LINTBALL_DIR}/tools/bin/uncrustify" ]]; then
    old="${PWD}"
    cd "${LINTBALL_DIR}/tools" || return $?
    find . -name "uncrustify*" -maxdepth 1 -exec rm -rf '{}' ';' || true
    curl -o uncrustify.tar.gz -L https://github.com/uncrustify/uncrustify/archive/refs/tags/uncrustify-0.76.0.tar.gz &&
      tar xzf uncrustify.tar.gz &&
      rm uncrustify.tar.gz &&
      set +f &&
      cd uncrustify* &&
      set -f &&
      mkdir build &&
      cd build &&
      cmake .. &&
      cmake --build . &&
      mkdir -p "${LINTBALL_DIR}/tools/bin" &&
      mv uncrustify "${LINTBALL_DIR}/tools/bin" || status=$?
    cd "${old}" || return $?
  fi
  find . -type d -name "uncrustify*" -maxdepth 1 -exec rm -rf '{}' ';' || true
  return "${status}"
}
