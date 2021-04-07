SHELL := /usr/bin/env bash

all-test: clean tf-plan-eks

.PHONY: clean
clean:
	rm -rf .terraform

.PHONY: tf-plan-eks
tf-plan-eks:
	terraform init -backend-config ./live/preprod/eu-west-1/application/dev/backend.conf -reconfigure source && terraform validate && terraform plan -var-file ./live/preprod/eu-west-1/application/dev/base.tfvars source

.PHONY: tf-apply-eks
tf-apply-eks:
	terraform init -backend-config ./live/preprod/eu-west-1/application/dev/backend.conf -reconfigure source && terraform validate && terraform apply -var-file ./live/preprod/eu-west-1/application/dev/base.tfvars -auto-approve source

.PHONY: tf-destroy-eks
tf-destroy-test:
	terraform init -backend-config ./live/preprod/eu-west-1/application/dev/backend.conf -reconfigure source && terraform validate && terraform destroy -var-file ./live/preprod/eu-west-1/application/dev/base.tfvars source -auto-approve source
