# docker details
DOCKER_REGISTRY=757701271750.dkr.ecr.ap-southeast-2.amazonaws.com
IMAGE_NAME=amp-jenkins-agent-tooling

# Vars
GIT_HASH := $(shell git rev-parse --short HEAD)
BUILD_ID := $(shell date +%Y%m%d%H%M%S)

# Tasks

build: build-image tag-image push-image

build-image:
	docker build -t $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) .

build-local:
	docker build -t $(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) .

tag-image:
	docker tag $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID)
	docker tag $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

push-image:
	aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $(DOCKER_REGISTRY)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID)
	docker push $(DOCKER_REGISTRY)/$(IMAGE_NAME):latest

image-cleanup:
	docker image prune -af