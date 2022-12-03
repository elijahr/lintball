ASDF_NIM_VERSION=ref:version-1-6
export ASDF_NIM_VERSION

install_nimpretty() {
  local cache_dir nim_dir nimpretty
  if [ ! -f "${LINTBALL_DIR}/tools/bin/nimpretty" ]; then
    cache_dir="${ASDF_DATA_DIR}/tmp/.cache"
    nim_dir="${ASDF_DATA_DIR}/installs/nim/${ASDF_NIM_VERSION//:/-}"
    nimpretty="${nim_dir}/bin/nimpretty"
    configure_asdf || return $?
    if [ ! -d "$nim_dir" ]; then
      asdf plugin-add nim || true
      mkdir -p "${cache_dir}"
      XDG_CACHE_HOME="${cache_dir}" asdf install nim || return $?
      asdf reshim
    fi
    if [ ! -f "$nimpretty" ]; then
      (
        cd "${nim_dir}" || return $?
        nim c nimpretty/nimpretty.nim || return $?
        mv nimpretty/nimpretty bin/nimpretty || return $?
      ) || return $?
    fi
    mv "$nimpretty" "${LINTBALL_DIR}/tools/bin/nimpretty"
    rm -rf "${cache_dir}"
    asdf plugin-remove nim
  fi
}
