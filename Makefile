

IMAGE := zengxu/kube-code-generator

default: build

.PHONY: build
build:
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE):latest -t $(IMAGE):v1.27.1 --push .
