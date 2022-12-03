ASDF_SHELLCHECK_VERSION=0.8.0
export ASDF_SHELLCHECK_VERSION

install_shellcheck() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/shellcheck/${ASDF_SHELLCHECK_VERSION}" ]; then
    configure_asdf || return $?
    asdf plugin-add shellcheck || true
    asdf install shellcheck || return $?
    asdf reshim
  fi
}
