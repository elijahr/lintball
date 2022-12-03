install_uncrustify() {
  # uncrustify build depends on python 3
  install_python || return $?
  if [ ! -f "${LINTBALL_DIR}/tools/bin/uncrustify" ]; then
    (
      cd "${LINTBALL_DIR}/tools"
      find . -name "uncrustify*" -maxdepth 1 -exec rm -rf '{}' ';' || true
      curl -o uncrustify.tar.gz -L https://github.com/uncrustify/uncrustify/archive/refs/tags/uncrustify-0.76.0.tar.gz
      tar xzf uncrustify.tar.gz
      rm uncrustify.tar.gz
      cd uncrustify*
      mkdir build
      cd build
      cmake ..
      cmake --build .
      mkdir -p "${LINTBALL_DIR}/tools/bin"
      mv uncrustify "${LINTBALL_DIR}/tools/bin"
    ) || return $?
  fi
  find . -type d -name "uncrustify*" -maxdepth 1 -exec rm -rf '{}' ';' || true
}
