#!/usr/bin/env bash

set -euxo pipefail

if [[ -n $(command -v jq) ]]; then
  lintball_version=$(jq -r .version ./package.json)
elif [[ -n $(command -v npm) ]]; then
  # shellcheck disable=SC2016
  lintball_version=$(npm -s run env echo '$npm_package_version')
else
  echo >&2
  echo "Could not find jq or npm. Please install one of them." >&2
  exit 1
fi
lintball_major_version=$(echo "${lintball_version}" | awk -F '.' '{print $1}')
lintball_minor_version=$(echo "${lintball_version}" | awk -F '.' '{print $2}')
branch_name_slug=$(git rev-parse --abbrev-ref HEAD | sed 's/[^a-zA-Z0-9]/-/g')
debian_version=bullseye
do_push_dockerhub=no
do_push_ghcr=no
do_push_local=no
testing=yes
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

declare -a dockerhub_manifests=(
  "docker.io/elijahru/lintball:latest"
  "docker.io/elijahru/lintball:${lintball_version}"
  "docker.io/elijahru/lintball:${lintball_major_version}.${lintball_minor_version}"
  "docker.io/elijahru/lintball:${lintball_major_version}"
)

declare -a ghcr_manifests=(
  "ghcr.io/elijahr/lintball:latest"
  "ghcr.io/elijahr/lintball:${branch_name_slug}"
)

declare -a local_manifests=(
  "localhost:5000/elijahru/lintball:latest"
  "localhost:5000/elijahru/lintball:${lintball_version}"
  "localhost:5000/elijahru/lintball:${lintball_major_version}.${lintball_minor_version}"
  "localhost:5000/elijahru/lintball:${lintball_major_version}"
  "localhost:5000/elijahru/lintball:${branch_name_slug}"
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
      --tag "localhost:5000/elijahru/lintball:latest-${arch}" \
      $@ \
      .
    docker push "localhost:5000/elijahru/lintball:latest-${arch}"
    docker pull "localhost:5000/elijahru/lintball:latest-${arch}"
  done
}

create_tags() {
  local manifest arch
  for manifest in "$@"; do
    for arch in "${archs[@]}"; do
      docker tag \
        "localhost:5000/elijahru/lintball:latest-${arch}" \
        "${manifest}-${arch}"
    done
  done
}

create_manifests() {
  local manifest arch
  for manifest in "$@"; do
    # docker manifest create "${manifest}"
    for arch in "${archs[@]}"; do
      docker manifest create --amend "${manifest}" "${manifest}-${arch}" ||
        docker manifest create "${manifest}" "${manifest}-${arch}"
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
  for manifest in "$@"; do
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

  for manifest in "$@"; do
    for arch in "${archs[@]}"; do
      docker push "${manifest}-${arch}"
    done
  done
}

push_manifests() {
  local manifest answer

  set +x
  echo "Going to push the following manifests to hub.docker.com:"

  for manifest in "$@"; do
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

  for manifest in "$@"; do
    docker manifest push "${manifest}"
  done
}

if [[ ${#@} -gt 0 ]]; then
  while [[ ${1:-} != "" ]]; do
    case "$1" in
      --push-dockerhub)
        shift
        do_push_dockerhub=yes
        ;;
      --push-ghcr)
        shift
        do_push_ghcr=yes
        ;;
      --push-local)
        shift
        do_push_local=yes
        ;;
      --yes)
        shift
        answer_yes=yes
        ;;
      --not-testing)
        shift
        testing=no
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
if [[ ${do_push_local} == "yes" ]]; then
  if [[ -z "$(docker ps -a -q --filter="name=registry")" ]]; then
    # start a local registry
    docker run -d -p 5000:5000 --restart=always --name registry registry:2
  fi
  create_tags "${local_manifests[@]}"
  push_tags "${local_manifests[@]}"
  create_manifests "${local_manifests[@]}"
  push_manifests "${local_manifests[@]}"
fi
if [[ ${do_push_dockerhub} == "yes" ]]; then
  create_tags "${dockerhub_manifests[@]}"
  push_tags "${dockerhub_manifests[@]}"
  create_manifests "${dockerhub_manifests[@]}"
  push_manifests "${dockerhub_manifests[@]}"
fi
if [[ ${do_push_ghcr} == "yes" ]]; then
  create_tags "${ghcr_manifests[@]}"
  push_tags "${ghcr_manifests[@]}"
  create_manifests "${ghcr_manifests[@]}"
  push_manifests "${ghcr_manifests[@]}"
fi
