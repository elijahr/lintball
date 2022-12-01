# shellcheck disable=SC2086,SC2230,SC2048,SC2164

configure_asdf() {
  local plugins
  if [ ! -d "${LINTBALL_DIR}/tools/asdf" ]; then
    git clone https://github.com/asdf-vm/asdf.git \
      --depth 1 \
      --branch v0.10.2 \
      "${LINTBALL_DIR}/tools/asdf"
    # disable `asdf update`
    touch "${LINTBALL_DIR}/tools/asdf/asdf_updates_disabled"
  fi
  source "${LINTBALL_DIR}/tools/asdf/asdf.sh"
  declare -a plugins=(nim python nodejs ruby rust shellcheck shfmt)
  for plugin in "${plugins[@]}"; do
    if [ ! -d "${LINTBALL_DIR}/tools/asdf/plugins/${plugin}" ]; then
      asdf plugin-add "${plugin}"
    fi
  done
}

install_bundler_requirements() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/ruby/${ASDF_RUBY_VERSION}" ]; then
    configure_asdf
    asdf install ruby
    asdf reshim
  fi
  (
    cd "${LINTBALL_DIR}/tools"
    gem install bundler
    bundle config set --local deployment 'false'
    bundle install
    rm -f Gemfile.lock
  ) || return $?
}

install_clippy() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/rust/${ASDF_RUST_VERSION}" ]; then
    configure_asdf
    asdf install rust
    asdf reshim
  fi
  rustup toolchain install nightly
  rustup self update
  rustup update
  rustup component add clippy --toolchain nightly
}

install_nimpretty() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/nim/${ASDF_NIM_VERSION}" ]; then
    configure_asdf
    asdf install nim
    asdf reshim
  fi
}

install_pip_requirements() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/python/${ASDF_PYTHON_VERSION}" ]; then
    configure_asdf
    asdf install python
    asdf reshim
  fi
  (
    cd "${LINTBALL_DIR}/tools"
    pip install -r requirements-pip.txt
  ) || return $?
}

install_prettier() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/nodejs/${ASDF_NODEJS_VERSION}" ]; then
    configure_asdf
    asdf install nodejs
    asdf reshim
  fi
  (
    cd "${LINTBALL_DIR}/tools"
    npm install
  ) || return $?
}

install_shellcheck() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/shellcheck/${ASDF_SHELLCHECK_VERSION}" ]; then
    configure_asdf
    asdf install shellcheck
    asdf reshim
  fi
}

install_shfmt() {
  if [ ! -d "${ASDF_DATA_DIR}/installs/shfmt/${ASDF_SHFMT_VERSION}" ]; then
    configure_asdf
    asdf install shfmt
    asdf reshim
  fi
}

install_stylua() {
  configure_asdf
  if [ ! -d "${ASDF_DATA_DIR}/installs/rust/${ASDF_RUST_VERSION}" ]; then
    asdf install rust
    asdf reshim
  fi
  cargo install stylua --features luau
}

install_uncrustify() {
  if [ ! -f "${LINTBALL_DIR}/tools/bin/uncrustify" ]; then
    (
      cd "${LINTBALL_DIR}/tools"
      tar xzf uncrustify-0.75.1.tar.gz
      cd uncrustify-0.75.1
      mkdir build
      cd build
      cmake ..
      cmake --build .
      mkdir -p "${LINTBALL_DIR}/tools/bin"
      mv uncrustify "${LINTBALL_DIR}/tools/bin"
    )
  fi
  if [ -d "${LINTBALL_DIR}/tools/uncrustify-0.75.1" ]; then
    rm -rf "${LINTBALL_DIR}/tools/uncrustify-0.75.1"
  fi
}
