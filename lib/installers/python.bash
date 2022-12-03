ASDF_PYTHON_VERSION=3.10.8
export ASDF_PYTHON_VERSION

install_python() {
  configure_asdf || return $?
  if [ ! -d "${ASDF_DATA_DIR}/installs/python/${ASDF_PYTHON_VERSION}" ]; then
    asdf plugin-add python || true
    asdf install python || return $?
    asdf reshim
  fi
  (
    cd "${LINTBALL_DIR}/tools"
    pip install -r pip-requirements.txt --no-cache-dir
    asdf reshim
  ) || return $?
}
