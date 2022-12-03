ASDF_RUBY_VERSION=3.0.0
export ASDF_RUBY_VERSION

BUNDLE_GEMFILE="${LINTBALL_DIR}/tools/Gemfile"
export BUNDLE_GEMFILE

install_ruby() {
  configure_asdf || return $?
  if [ ! -d "${ASDF_DATA_DIR}/installs/ruby/${ASDF_RUBY_VERSION}" ]; then
    asdf plugin-add ruby || true
    asdf install ruby || return $?
    asdf reshim
  fi
  (
    cd "${LINTBALL_DIR}/tools"
    gem install bundler
    bundle config set --local deployment 'false'
    bundle install
    gem sources --clear-all
    asdf reshim
  ) || return $?
}
