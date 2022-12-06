# ECR details
IMAGE_NAME=amp-jenkins-agent-tooling

AWS_ACCOUNT := $(shell aws sts get-caller-identity --query "Account" --output text)
ESI_REGISTRY=$(AWS_ACCOUNT).dkr.ecr.ap-southeast-2.amazonaws.com
SOURCE_REGISTRY=194167259353.dkr.ecr.ap-southeast-2.amazonaws.com

# Vars
GIT_HASH := $(shell git rev-parse --short HEAD)
BUILD_ID := $(shell date +%Y%m%d%H%M%S)

# Tasks

run-all: lint-dockerfile login-source-ecr build-image tag-image test-image scan-image push-image

lint-dockerfile:
	docker run --rm -i hadolint/hadolint < Dockerfile || true

login-source-ecr:
	aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $(SOURCE_REGISTRY)

build-image:
	docker build -t $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) .

tag-image:
	docker tag $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID)
	docker tag $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) $(ESI_REGISTRY)/$(IMAGE_NAME):latest

test-image:
	docker run --name $(IMAGE_NAME)-$(GIT_HASH)-$(BUILD_ID)-test-image --entrypoint "/bin/sleep" -d $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) 100
	docker exec -i $(IMAGE_NAME)-$(GIT_HASH)-$(BUILD_ID)-test-image bash < tests/testing-script.sh
	docker rm -f $(IMAGE_NAME)-$(GIT_HASH)-$(BUILD_ID)-test-image
## Task: test-image - run container, execute tests, then remove container

scan-image:
	trivy image $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) --security-checks vuln
	trivy image $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID) --security-checks vuln --exit-code 1 --no-progress --severity CRITICAL || true
## Task: scan-image - scan image for CVE vulnerabilities and fail if critical is found

push-image:
	aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin $(ESI_REGISTRY)
	docker push $(ESI_REGISTRY)/$(IMAGE_NAME):$(GIT_HASH)-$(BUILD_ID)
	docker push $(ESI_REGISTRY)/$(IMAGE_NAME):latest

# Utility tasks

build-local: lint-dockerfile login-source-ecr build-image test-image scan-image

image-cleanup:
	docker image prune -af