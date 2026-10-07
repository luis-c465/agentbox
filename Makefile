VERSION ?=
IMAGE_PREFIX ?= agentbox
PLATFORM ?=
DOCKER_CONTEXT ?=
BOX_IMAGE ?= ghcr.io/madarco/agentbox/box:0.33.0
BASE_IMAGE ?= $(IMAGE_PREFIX)/base:latest

IMAGES := $(patsubst images/%/Dockerfile,%,$(wildcard images/*/Dockerfile))
BUILD_ARGS_base = --build-arg BOX_IMAGE=$(BOX_IMAGE)
BUILD_ARGS_cua = --build-arg BASE_IMAGE=$(BASE_IMAGE)

.DEFAULT_GOAL := help
.PHONY: help build

help:
	@echo 'Usage: make build <image> [VERSION=<version>] [PLATFORM=<platform>]'
	@echo 'Available images: $(IMAGES)'
	@echo 'Always tags latest; VERSION adds a second tag. Builds only the selected image.'
	@echo 'Overrides: IMAGE_PREFIX, BOX_IMAGE, BASE_IMAGE, DOCKER_CONTEXT'
	@echo 'DOCKER_CONTEXT selects a Docker context and its named builder; empty keeps local behavior.'
	@echo 'Use a Docker-driver Buildx builder on the target context for daemon-local parent images.'

ifneq ($(filter build,$(MAKECMDGOALS)),)
SELECTED_IMAGE := $(filter-out build,$(MAKECMDGOALS))
ifneq ($(words $(SELECTED_IMAGE)),1)
$(error Usage: make build <image> [VERSION=<version>]; select exactly one image from: $(IMAGES))
endif
ifeq ($(filter $(SELECTED_IMAGE),$(IMAGES)),)
$(error Unknown image '$(SELECTED_IMAGE)'; available images: $(IMAGES))
endif

# Make treats the image selector as another goal; the actual build runs once below.
.PHONY: $(SELECTED_IMAGE)
$(SELECTED_IMAGE):
	@:

build:
	docker $(if $(DOCKER_CONTEXT),--context $(DOCKER_CONTEXT)) buildx build $(if $(DOCKER_CONTEXT),--builder $(DOCKER_CONTEXT)) --load $(if $(PLATFORM),--platform $(PLATFORM)) \
		--tag $(IMAGE_PREFIX)/$(SELECTED_IMAGE):latest \
		$(if $(filter-out latest,$(VERSION)),--tag $(IMAGE_PREFIX)/$(SELECTED_IMAGE):$(VERSION)) \
		$(BUILD_ARGS_$(SELECTED_IMAGE)) images/$(SELECTED_IMAGE)
else
build:
	@$(MAKE) --no-print-directory help
endif
