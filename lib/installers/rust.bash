# shellcheck disable=SC2154

install_clippy() {
  if [[ ! -f "${LINTBALL_DIR}/tools/asdf/shims/clippy" ]]; then
    configure_asdf
    if [[ ! -d "${ASDF_DATA_DIR}/installs/rust/${ASDF_RUST_VERSION}" ]]; then
      asdf plugin-add rust
      asdf install rust
      asdf reshim
    fi
    rustup component add clippy
    asdf reshim || true
  fi
}

install_stylua() {
  if [[ ! -f "${LINTBALL_DIR}/tools/asdf/shims/stylua" ]]; then
    configure_asdf
    if [[ ! -d "${ASDF_DATA_DIR}/installs/rust/${ASDF_RUST_VERSION}" ]]; then
      asdf plugin-add rust
      asdf install rust
      asdf reshim
    fi
    # without -Z sparse-registry, this fails with code 137 (OOM) on docker builds
    # see https://www.reddit.com/r/docker/comments/z9vxvj/docker_buildx_gives_exit_code_137_with_cargo/
    rustup toolchain install nightly
    cargo +nightly install stylua --features luau -Z sparse-registry
    asdf reshim || true
  fi
}
