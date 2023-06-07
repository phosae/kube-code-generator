#!/usr/bin/env bash

# Usage: 
#     update-generated-protobuf.sh "${APIROOTS[@]}"
#     An example APIROOT is: "k8s.io/api/admissionregistration/v1"

set -eufo pipefail

BOILERPLATE_PATH=/tmp/fake-boilerplate.txt
[[ -f ${BOILERPLATE_PATH} ]] || touch ${BOILERPLATE_PATH}

go-to-protobuf \
    --proto-import=/go/src \
    --proto-import=/go/src/k8s.io/kubernetes/third_party/protobuf \
    --packages "$(IFS=, ; echo "$*")" \
    --output-base /go/src/ \
    --go-header-file "${BOILERPLATE_PATH}"