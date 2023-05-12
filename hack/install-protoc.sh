#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PROTOC_VERSION=3.19.4
SCRIPT_ROOT=$(dirname "${BASH_SOURCE[0]}")

download_folder="protoc-v${PROTOC_VERSION}-${OS}-${ARCH}"
download_file="${download_folder}.zip"

cd "${SCRIPT_ROOT}" || return 1

if [[ $(readlink protoc) != "${download_folder}" ]]; then
    if [[ ${OS} == "darwin" ]]; then
    url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-osx-x86_64.zip"
    elif [[ ${OS} == "linux" && ${ARCH} == "amd64" ]]; then
    url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip"
    elif [[ ${OS} == "linux" && ${ARCH} == "arm64" ]]; then
    url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-aarch_64.zip"
    else
    echo "This install script does not support ${OS}/${ARCH}"
    return 1
    fi
    curl -fsSL --retry 3 --keepalive-time 2 "${url}" -o "${download_file}"
    unzip -o "${download_file}" -d "${download_folder}"
    ln -fns "${download_folder}" protoc
    mv protoc/bin/protoc protoc/protoc
    chmod -R +rX protoc/protoc
    rm -fr protoc/include
    rm "${download_file}"
fi