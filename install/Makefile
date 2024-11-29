BIN = $(shell pwd)/bin
include .env
export $(shell sed 's/=.*//' .env)
$(shell [ -f bin ] || mkdir -p $(BIN))

.DEFAULT_GOAL := build
APP = install
GOBIN = go
PATH := $(BIN):$(PATH)
GOARCH = amd64
LDFLAGS = -extldflags '-static' -w -s -buildid= 
GCFLAGS = all=-trimpath=$(shell pwd) -dwarf=false -l
ASMFLAGS = all=-trimpath=$(shell pwd)
TEST_SSH = "astra@192.168.200.160"

build: build-bin .crop ## Build all

build-bin: ## Build for debian
	CGO_ENABLED=0 GOOS=linux GOARCH=$(GOARCH) \
	  $(GOBIN) build -ldflags="$(LDFLAGS)" -trimpath -gcflags="$(GCFLAGS)" -asmflags="$(ASMFLAGS)" \
	  -o $(BIN)/$(APP) cmd/$(APP)/main.go

test: build
	scp $(BIN)/$(APP) $(TEST_SSH):~/
	scp ../*.tar.gz $(TEST_SSH):~/
	scp ../incus $(TEST_SSH):~/
	scp ../incus-migrate $(TEST_SSH):~/
	ssh $(TEST_SSH) 'echo astra | sudo -S ./$(APP)'

.crop:
	for file in $(wildcard $(BIN)/$(APP)_*); do \
		strip $$file; \
		objcopy --strip-unneeded $$file; \
	done

help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
