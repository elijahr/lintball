# shellcheck disable=SC2154

ASDF_NODEJS_VERSION=18.12.1
export ASDF_NODEJS_VERSION

if [[ ${LIBC_TYPE} == "musl" ]]; then
  # binary nodejs doesn't run on alpine / musl
  # see https://github.com/asdf-vm/asdf-nodejs/issues/190
  ASDF_NODEJS_FORCE_COMPILE=1
  export ASDF_NODEJS_FORCE_COMPILE
fi

install_nodejs() {
  local old status
  configure_asdf
  if [[ ! -d "${ASDF_DATA_DIR}/installs/nodejs/${ASDF_NODEJS_VERSION}" ]]; then
    asdf plugin-add nodejs || true
    asdf install nodejs
    asdf reshim
  fi
  old="${PWD}"
  cd "${LINTBALL_DIR}/tools" || return $?
  status=0
  npm install || status=$?
  npm cache clean --force || status=$?
  cd "${old}" || return $?
  asdf reshim
  return "${status}"
}
