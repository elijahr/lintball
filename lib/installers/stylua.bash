# shellcheck disable=SC2154

ASDF_RUST_VERSION=1.65.0
export ASDF_RUST_VERSION

# Allow rustup installation
RUSTUP_INIT_SKIP_PATH_CHECK=yes
export RUSTUP_INIT_SKIP_PATH_CHECK

install_stylua() {
  if [[ ! -f "${LINTBALL_DIR}/tools/bin/stylua" ]]; then
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
    mv "${ASDF_DATA_DIR}/installs/rust/${ASDF_RUST_VERSION}/bin/stylua" \
      "${LINTBALL_DIR}/tools/bin/stylua"
    asdf plugin-remove rust
    asdf reshim || true
  fi
}
