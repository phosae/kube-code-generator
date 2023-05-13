FROM golang:1.20.4-bullseye
ARG TARGETOS
ARG TARGETARCH
ARG KUBE_VERSION="1.27.1"
ARG CODEGEN_VERSION="0.27.1"
ARG CONTROLLER_GEN_VERSION="0.12.0"

ENV OS=${TARGETOS}
ENV ARCH=${TARGETARCH}

RUN apt-get update && \
    apt-get install -y \
    git \
    unzip

# Code generator stuff
RUN wget http://github.com/kubernetes/kubernetes/archive/v${KUBE_VERSION}.tar.gz && \
    mkdir -p /go/src/k8s.io/code-generator/ && \
    mkdir -p /go/src/k8s.io/apimachinery/ && \
    mkdir -p /go/src/github.com/gogo/ && \
    mkdir -p /go/src/k8s.io/kubernetes/third_party/protobuf/ && \
    tar zxvf v${KUBE_VERSION}.tar.gz --strip 5 -C /go/src/k8s.io/code-generator/ kubernetes-${KUBE_VERSION}/staging/src/k8s.io/code-generator && \
    tar zxvf v${KUBE_VERSION}.tar.gz --strip 5 -C /go/src/k8s.io/apimachinery/ kubernetes-${KUBE_VERSION}/staging/src/k8s.io/apimachinery && \
    tar zxvf v${KUBE_VERSION}.tar.gz --strip 4 -C /go/src/github.com/gogo/ kubernetes-${KUBE_VERSION}/vendor/github.com/gogo && \
    tar zxvf v${KUBE_VERSION}.tar.gz --strip 3 -C /go/src/k8s.io/kubernetes/third_party/protobuf/ kubernetes-${KUBE_VERSION}/third_party/protobuf && \
    rm v${KUBE_VERSION}.tar.gz && \
    \
    cd /go/src/k8s.io/code-generator/ && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/bin/protoc-gen-gogo ./cmd/go-to-protobuf/protoc-gen-gogo && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /usr/bin/go-to-protobuf  ./cmd/go-to-protobuf && \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOBIN=/usr/bin go install golang.org/x/tools/cmd/goimports@latest && \
    cd - && \
    \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOBIN=/usr/bin go install sigs.k8s.io/controller-tools/cmd/controller-gen@v${CONTROLLER_GEN_VERSION} && \
    rm -rf /go/pkg

COPY hack/install-protoc.sh /go/install-protoc.sh
RUN /go/install-protoc.sh
ENV PATH="${PATH}:/go/protoc"

# Create user
ARG uid=1000
ARG gid=1000
RUN addgroup --gid $gid codegen && \
    adduser --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password --uid $uid --ingroup codegen codegen && \
    chown codegen:codegen -R /go

COPY hack /hack
RUN chown codegen:codegen -R /hack && \
    mv /hack/update* /usr/bin

USER codegen

WORKDIR /usr/bin

CMD ["update-codegen.sh"]
