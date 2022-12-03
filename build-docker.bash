#!/usr/bin/env bash

set -uexo pipefail

debian_version=bullseye-slim
lintball_version=$(jq -r .version ./package.json)
lintball_major_version=$(echo "$lintball_version" | awk -F '.' '{print $1}')
lintball_minor_version=$(echo "$lintball_version" | awk -F '.' '{print $2}')
do_push=no
answer_yes=no

declare -a archs=(arm64 amd64)

DOCKER_BUILDKIT=1
export DOCKER_BUILDKIT

declare -A docker_manifest_args=(
  [amd64]="--arch amd64"
  [arm64]="--arch arm64 --variant v8"
)

declare -a manifests=(
  docker.io/elijahru/lintball:latest
  "docker.io/elijahru/lintball:${lintball_version}"
  "docker.io/elijahru/lintball:${lintball_major_version}.${lintball_minor_version}"
  "docker.io/elijahru/lintball:${lintball_major_version}"
)

build() {
  # Build with legacy Docker build
  for arch in "${archs[@]}"; do
    docker build \
      --platform "linux/${arch}" \
      --build-arg "DEBIAN_VERSION=${debian_version}" \
      --build-arg "LINTBALL_VERSION=${lintball_version}" \
      --file Dockerfile \
      --tag "docker.io/elijahru/lintball:latest-${arch}" \
      . || return $?
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
    docker manifest create "${manifest}" || return $?
    for arch in "${archs[@]}"; do
      docker manifest create --amend "${manifest}" "${manifest}-${arch}"
      docker manifest annotate "${manifest}" --os linux "${docker_manifest_args[$arch]}"
    done
  done
}

push_tags() {
  local manifest arch answer
  set +x
  echo
  echo "Will push the following tags:"
  echo
  for manifest in "${manifests[@]}"; do
    for arch in "${archs[@]}"; do
      echo "- ${manifest}-${arch}"
    done
  done
  echo

  if [ "$answer_yes" != "yes" ]; then
    while true; do
      printf '%s' "Is this correct? [y/n] "
      read -r answer
      case "$answer" in
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
    for arch in "${archs[@]}"; do
      docker push "${manifest}-${arch}" || return $?
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
    docker manifest inspect "${manifest}" || return $?
    echo
  done

  if [ "$answer_yes" != "yes" ]; then
    while true; do
      printf '%s' "Is this correct? [y/n] "
      read -r answer
      case "$answer" in
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
    docker manifest push "${manifest}" || return $?
  done
}

if [ "${#@}" -gt 0 ]; then
  while [ "${1:-}" != "" ]; do
    case "$1" in
      --push)
        shift
        do_push=yes
        ;;
      --yes)
        shift
        answer_yes=yes
        ;;
      *)
        echo "Unhandled argument: $1" >&2
        exit 1
        ;;
    esac
  done
fi

build || exit $?
create_tags || exit $?
if [ "$do_push" = "yes" ]; then
  push_tags || exit $?
  create_manifests || exit $?
  push_manifests || exit $?
fi
