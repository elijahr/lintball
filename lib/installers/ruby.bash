# shellcheck disable=SC2154

ASDF_RUBY_VERSION=3.0.0
export ASDF_RUBY_VERSION

BUNDLE_GEMFILE="${LINTBALL_DIR}/tools/Gemfile"
export BUNDLE_GEMFILE

install_ruby() {
  local old status
  configure_asdf
  if [[ ! -d "${ASDF_DATA_DIR}/installs/ruby/${ASDF_RUBY_VERSION}" ]]; then
    asdf plugin-add ruby || true
    asdf install ruby
    asdf reshim
  fi
  old="${PWD}"
  cd "${LINTBALL_DIR}/tools" || return $?
  status=0
  gem install bundler &&
    bundle config set --local deployment 'false' &&
    bundle install &&
    gem sources --clear-all ||
    status=$?
  asdf reshim
  cd "${old}" || return $?
  return "${status}"
}
