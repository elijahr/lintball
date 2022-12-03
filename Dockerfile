# syntax=docker/dockerfile:1

# Dockerfile optimized to build lintball's dependencies in parallel and pare
# down to the smallest possible output image.

ARG DEBIAN_VERSION
FROM --platform=$TARGETPLATFORM debian:${DEBIAN_VERSION} AS lintball-builder
ENV LINTBALL_DIR=/lintball

# Install deps
RUN apt update && apt install -y gnupg && \
    echo "deb http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main" >> /etc/apt/sources.list.d/apt-fast.list && \
    echo "deb-src http://ppa.launchpad.net/apt-fast/stable/ubuntu bionic main" >> /etc/apt/sources.list.d/apt-fast.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A2166B8DE8BDC3367D1901C11EE2FF37CA8DA16B && \
    echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections && \
    echo debconf apt-fast/dlflag boolean true | debconf-set-selections && \
    echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections && \
    apt update && apt install -y apt-fast && apt-fast install -y \
      build-essential bzip2 ca-certificates cmake coreutils curl gcc git \
      libbz2-1.0 libbz2-dev libc-dev libffi-dev libreadline-dev libssl1.1 \
      libssl-dev lzma make ncurses-dev openssh-client openssl perl uuid \
      xz-utils zlib1g zlib1g-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

RUN mkdir -p "${LINTBALL_DIR}/configs" && \
    mkdir -p "${LINTBALL_DIR}/lib/installers" && \
    mkdir -p "${LINTBALL_DIR}/tools/bin"

# Basic scripts for installing/configuring asdf
COPY configs/asdfrc "${LINTBALL_DIR}/configs/asdfrc"
COPY lib/env.bash "${LINTBALL_DIR}/lib/env.bash"
COPY lib/install.bash "${LINTBALL_DIR}/lib/install.bash"
COPY lib/installers/asdf.bash "${LINTBALL_DIR}/lib/installers/asdf.bash"

RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && configure_asdf"

FROM --platform=$TARGETPLATFORM lintball-builder as lintball-ruby
COPY lib/installers/ruby.bash "${LINTBALL_DIR}/lib/installers/ruby.bash"
COPY tools/Gemfile "${LINTBALL_DIR}/tools/Gemfile"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_ruby"

FROM --platform=$TARGETPLATFORM lintball-builder as lintball-nimpretty
COPY lib/installers/nim.bash "${LINTBALL_DIR}/lib/installers/nim.bash"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_nimpretty"

FROM --platform=$TARGETPLATFORM lintball-builder as lintball-shellcheck
COPY lib/installers/shellcheck.bash "${LINTBALL_DIR}/lib/installers/shellcheck.bash"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_shellcheck"

FROM --platform=$TARGETPLATFORM lintball-builder as lintball-shfmt
COPY lib/installers/shfmt.bash "${LINTBALL_DIR}/lib/installers/shfmt.bash"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_shfmt"

FROM --platform=$TARGETPLATFORM lintball-builder as lintball-stylua
COPY lib/installers/stylua.bash "${LINTBALL_DIR}/lib/installers/stylua.bash"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_stylua"

FROM --platform=$TARGETPLATFORM lintball-builder as lintball-python
COPY lib/installers/python.bash "${LINTBALL_DIR}/lib/installers/python.bash"
COPY tools/pip-requirements.txt "${LINTBALL_DIR}/tools/pip-requirements.txt"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_python"

# uncrustify build depends on python
FROM --platform=$TARGETPLATFORM lintball-python as lintball-uncrustify
COPY lib/installers/uncrustify.bash "${LINTBALL_DIR}/lib/installers/uncrustify.bash"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_uncrustify"

# prettier build depends on python
FROM --platform=$TARGETPLATFORM lintball-python as lintball-nodejs
COPY lib/installers/nodejs.bash "${LINTBALL_DIR}/lib/installers/nodejs.bash"
COPY tools/package.json "${LINTBALL_DIR}/tools/package.json"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && install_nodejs"

FROM --platform=$TARGETPLATFORM debian:${DEBIAN_VERSION} as lintball-composite
ENV LINTBALL_DIR=/lintball
COPY --from=lintball-builder "${LINTBALL_DIR}/tools/asdf" "${LINTBALL_DIR}/tools/asdf"
COPY --from=lintball-ruby "${LINTBALL_DIR}/tools/asdf/installs/ruby" "${LINTBALL_DIR}/tools/asdf/installs/ruby"
COPY --from=lintball-ruby "${LINTBALL_DIR}/tools/asdf/plugins/ruby" "${LINTBALL_DIR}/tools/asdf/plugins/ruby"
COPY --from=lintball-nimpretty "${LINTBALL_DIR}/tools/bin/nimpretty" "${LINTBALL_DIR}/tools/bin/nimpretty"
COPY --from=lintball-nodejs "${LINTBALL_DIR}/tools/asdf/installs/nodejs" "${LINTBALL_DIR}/tools/asdf/installs/nodejs"
COPY --from=lintball-nodejs "${LINTBALL_DIR}/tools/asdf/plugins/nodejs" "${LINTBALL_DIR}/tools/asdf/plugins/nodejs"
COPY --from=lintball-nodejs "${LINTBALL_DIR}/tools/node_modules" "${LINTBALL_DIR}/tools/node_modules"
COPY --from=lintball-python "${LINTBALL_DIR}/tools/asdf/installs/python" "${LINTBALL_DIR}/tools/asdf/installs/python"
COPY --from=lintball-python "${LINTBALL_DIR}/tools/asdf/plugins/python" "${LINTBALL_DIR}/tools/asdf/plugins/python"
COPY --from=lintball-shellcheck "${LINTBALL_DIR}/tools/asdf/installs/shellcheck" "${LINTBALL_DIR}/tools/asdf/installs/shellcheck"
COPY --from=lintball-shellcheck "${LINTBALL_DIR}/tools/asdf/plugins/shellcheck" "${LINTBALL_DIR}/tools/asdf/plugins/shellcheck"
COPY --from=lintball-shfmt "${LINTBALL_DIR}/tools/asdf/installs/shfmt" "${LINTBALL_DIR}/tools/asdf/installs/shfmt"
COPY --from=lintball-shfmt "${LINTBALL_DIR}/tools/asdf/plugins/shfmt" "${LINTBALL_DIR}/tools/asdf/plugins/shfmt"
COPY --from=lintball-stylua "${LINTBALL_DIR}/tools/bin/stylua" "${LINTBALL_DIR}/tools/bin/stylua"
COPY --from=lintball-uncrustify "${LINTBALL_DIR}/tools/bin/uncrustify" "${LINTBALL_DIR}/tools/bin/uncrustify"
COPY bin "${LINTBALL_DIR}/bin"
COPY configs "${LINTBALL_DIR}/configs"
COPY githooks "${LINTBALL_DIR}/githooks"
COPY lib "${LINTBALL_DIR}/lib"
COPY .lintballrc.json "${LINTBALL_DIR}/.lintballrc.json"
COPY LICENSE "${LINTBALL_DIR}/LICENSE"
COPY package.json "${LINTBALL_DIR}/package.json"
COPY README.md "${LINTBALL_DIR}/README.md"
RUN bash -c "set -euxo pipefail && source ${LINTBALL_DIR}/lib/env.bash && source ${LINTBALL_DIR}/lib/install.bash && configure_asdf && asdf reshim"

# may not be needed after build?
#COPY tools/Gemfile "${LINTBALL_DIR}/"
#COPY tools/package.json "${LINTBALL_DIR}/"

# Output image does not inherit from lintball-builder because we don't need all
# of the installed debian packages.
FROM --platform=$TARGETPLATFORM debian:${DEBIAN_VERSION} as lintball
ENV LINTBALL_DIR=/lintball
COPY --from=lintball-composite "${LINTBALL_DIR}" "${LINTBALL_DIR}"
# VOLUME ["${LINTBALL_DIR}/tools"]
CMD ["/bin/bash"]

