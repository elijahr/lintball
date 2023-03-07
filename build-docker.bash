#!/usr/bin/env bash

set -euxo pipefail

debian_version=bullseye
lintball_version=$(jq -r .version ./package.json)
lintball_major_version=$(echo "${lintball_version}" | awk -F '.' '{print $1}')
lintball_minor_version=$(echo "${lintball_version}" | awk -F '.' '{print $2}')
do_push=no
testing=no
answer_yes=no

declare -a archs=(
  arm64
  # amd64
)

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

declare -A docker_manifest_args=(
  [amd64]="--arch amd64"
  [arm64]="--arch arm64 --variant v8"
)

declare -a manifests=(
  "docker.io/elijahru/lintball:latest"
  "docker.io/elijahru/lintball:${lintball_version}"
  "docker.io/elijahru/lintball:${lintball_major_version}.${lintball_minor_version}"
  "docker.io/elijahru/lintball:${lintball_major_version}"
)

build() {
  # Build with legacy Docker build
  for arch in "${archs[@]}"; do
    # shellcheck disable=SC2068
    docker build \
      --platform "linux/${arch}" \
      --build-arg "DEBIAN_VERSION=${debian_version}" \
      --build-arg "TESTING=${testing}" \
      --file Dockerfile \
      --tag "docker.io/elijahru/lintball:latest-${arch}" \
      $@ \
      .
  done
}

create_tags() {
  local manifest arch
  for manifest in "${manifests[@]:1}"; do
    for arch in "${archs[@]}"; do
      docker tag \
        "docker.io/elijahru/lintball:latest-${arch}" \
        "${manifest}-${arch}"
    done
  done
}

create_manifests() {
  local manifest arch
  for manifest in "${manifests[@]}"; do
    docker manifest create "${manifest}"
    for arch in "${archs[@]}"; do
      docker manifest create --amend "${manifest}" "${manifest}-${arch}"
      docker manifest annotate "${manifest}" --os linux "${docker_manifest_args[${arch}]}"
    done
  done
}

push_tags() {
  local manifest arch answer
  set +x
  echo >&2
  echo "Will push the following tags:" >&2
  echo >&2
  for manifest in "${manifests[@]}"; do
    for arch in "${archs[@]}"; do
      echo "- ${manifest}-${arch}" >&2
    done
  done
  echo >&2

  if [[ ${answer_yes} != "yes" ]]; then
    while true; do
      printf '%s' "Is this correct? [y/n] " >&2
      read -r answer
      case "${answer}" in
        y | Y | yes) break ;;
        n | N | no)
          set -x
          return 1
          ;;
        *) echo "${answer@Q} is not a valid answer." >&2 ;;
      esac
    done
  fi
  set -x

  for manifest in "${manifests[@]}"; do
    for arch in "${archs[@]}"; do
      docker push "${manifest}-${arch}"
    done
  done
}

push_manifests() {
  local manifest answer

  set +x
  echo "Going to push the following manifests to hub.docker.com:"

  for manifest in "${manifests[@]}"; do
    echo
    echo "- ${manifest}"
    docker manifest inspect "${manifest}"
    echo
  done

  if [[ ${answer_yes} != "yes" ]]; then
    while true; do
      printf '%s' "Is this correct? [y/n] "
      read -r answer
      case "${answer}" in
        y | Y | yes) break ;;
        n | N | no)
          set -x
          return 1
          ;;
        *) echo "${answer@Q} is not a valid answer." ;;
      esac
    done
  fi
  set -x

  for manifest in "${manifests[@]}"; do
    docker manifest push "${manifest}"
  done
}

if [[ ${#@} -gt 0 ]]; then
  while [[ ${1:-} != "" ]]; do
    case "$1" in
      --push)
        shift
        do_push=yes
        ;;
      --yes)
        shift
        answer_yes=yes
        ;;
      --testing)
        shift
        testing=yes
        ;;
      --single-arch)
        shift
        # only build for the specified architecture
        archs=("$1")
        shift
        ;;
      --)
        # remaining args get passed to docker build
        shift
        break
        ;;
      *)
        echo "Unhandled argument: $1" >&2
        exit 1
        ;;
    esac
  done
fi

build "$@"
create_tags
if [[ ${do_push} == "yes" ]]; then
  push_tags
  create_manifests
  push_manifests
fi
