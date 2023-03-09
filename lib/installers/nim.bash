# shellcheck disable=SC2154

install_nimpretty() {
  local cache_dir nim_dir nimpretty status old
  status=0
  if [[ ! -f "${LINTBALL_DIR}/tools/bin/nimpretty" ]]; then
    cache_dir="${ASDF_DATA_DIR}/tmp/.cache"
    nim_dir="${ASDF_DATA_DIR}/installs/nim/${ASDF_NIM_VERSION//:/-}"
    nimpretty="${nim_dir}/bin/nimpretty"
    configure_asdf
    if [[ ! -d ${nim_dir} ]]; then
      asdf plugin-add nim || true
      mkdir -p "${cache_dir}"
      XDG_CACHE_HOME="${cache_dir}" asdf install nim
      asdf reshim
    fi
    if [[ ! -f ${nimpretty} ]]; then
      old="${PWD}"
      cd "${nim_dir}" || return $?
      nim c nimpretty/nimpretty.nim &&
        mv nimpretty/nimpretty bin/nimpretty || status=$?
      cd "${old}" || return $?
    fi
    mkdir -p "${LINTBALL_DIR}/tools/bin"
    mv "${nimpretty}" "${LINTBALL_DIR}/tools/bin/nimpretty"
    rm -rf "${cache_dir}"
    asdf plugin-remove nim
  fi
  return "${status}"
}
