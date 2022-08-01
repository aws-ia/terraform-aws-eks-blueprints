# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
GOLANG_VERSION ?= 1.12.4
GOPATH ?= $(HOME)/go
PYTHON_BIN ?= python
export KUSTOMIZE_BIN ?= kustomize

# Comma seperated items within {} for more than one file
# EXCLUDE ?= istio-install-base_test.go

export GO111MODULE = on
export GO = go

all: test

generate:
	$(PYTHON_BIN) ./generate_tests.py --all
	$(GO) fmt ./...

generate-changed-only:
	$(PYTHON_BIN) ./generate_tests.py
	$(GO) fmt ./...

modules:
	@GO111MODULE=on $(GO) mod download

test: modules
	@GO111MODULE=on $(GO) test -v ./awsconfigs/...
	@GO111MODULE=on $(GO) test -run TestCheckWebhookSelector -v github.com/kubeflow/manifests/tests/.
	@GO111MODULE=on $(GO) test -run TestKustomizationHasDeprecatedEnv -v github.com/kubeflow/manifests/tests/.
