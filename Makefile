SHELL := /usr/bin/env bash

all-test: clean tf-plan-eks

.PHONY: clean
clean:
	rm -rf source/.terraform

.PHONY: tf-plan-eks
tf-plan-eks:
	cd source && terraform init -backend-config ../live/preprod/eu-west-1/application/dev/backend.conf -reconfigure && terraform validate && terraform plan -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars

.PHONY: tf-apply-eks
tf-apply-eks:
	cd source && terraform init -backend-config ../live/preprod/eu-west-1/application/dev/backend.conf -reconfigure && terraform validate && terraform apply -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars -auto-approve

.PHONY: tf-destroy-eks
tf-destroy-test:
	cd source && terraform init -backend-config ../live/preprod/eu-west-1/application/dev/backend.conf -reconfigure && terraform validate && terraform destroy -var-file ../live/preprod/eu-west-1/application/dev/base.tfvars -auto-approve
