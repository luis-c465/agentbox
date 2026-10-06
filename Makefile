PLATFORM ?= linux/amd64
VERSION ?= dev
BASE_IMAGE ?= agentbox/base:$(VERSION)
CUA_IMAGE ?= agentbox/cua:$(VERSION)

.PHONY: build-base build-cua check install-cua-skills

build-base:
	docker build --platform $(PLATFORM) -t $(BASE_IMAGE) images/base

build-cua: build-base
	docker build --platform $(PLATFORM) --build-arg BASE_IMAGE=$(BASE_IMAGE) -t $(CUA_IMAGE) images/cua
