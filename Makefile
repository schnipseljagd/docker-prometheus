.PHONY: all build

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD 2>/dev/null)
DOCKER_IMAGE := prometheus$(if $(GIT_BRANCH),:$(GIT_BRANCH))

default: build

run: build
	docker rm -f prometheus 2&> /dev/null || true
	docker run --name prometheus -p 9090:9090 -p 9092:9092 -p 9093:9093 -p 9094:9094 -e AWS_ACCESS_KEY=$(AWS_ACCESS_KEY) -e AWS_SECRET_KEY=$(AWS_SECRET_KEY) "$(DOCKER_IMAGE)"

build:
	docker build -t "$(DOCKER_IMAGE)" .
