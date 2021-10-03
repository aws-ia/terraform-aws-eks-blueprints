SHELL := /usr/bin/env bash

# HOW TO EXECUTE

# Executing Terraform PLAN
#	$ make tf-plan-eks env=<env> region=<region> account=<account> subenv=<subenv>
#    e.g.,
#       make tf-plan-eks env=preprod region=eu-west-1 account=application subenv=dev

# Executing Terraform APPLY
#   $ make tf-apply-eks env=<env> region=<region> account=<account> subenv=<subenv>

# Executing Terraform DESTROY
#	$ make tf-destroy-eks env=<env> region=<region> account=<account> subenv=<subenv>

# Example for running the dev config in preprod ->  live/preprod/eu-west-1/application/dev/test-eks.tfvars
#  $ make tf-plan-eks env=preprod region=eu-west-1 account=application subenv=dev

# Example for running the dev config in preprod ->  live/preprod/eu-west-1/gaming/test/test-eks.tfvars
#  $make tf-plan-eks env=preprod region=eu-west-1 account=gaming subenv=test


all-test: clean tf-plan-eks

.PHONY: clean
clean:
	rm -rf .terraform .terraform.lock.hcl

.PHONY: tf-plan-eks
tf-plan-eks:
	export AWS_REGION=${region} && terraform init -backend-config ./deploy/live/${env}/${region}/${account}/${subenv}/backend.conf -reconfigure && terraform validate && terraform plan -var-file ./deploy/live/${env}/${region}/${account}/${subenv}/${subenv}.tfvars -refresh=false

.PHONY: tf-apply-eks
tf-apply-eks:
	export AWS_REGION=${region} && terraform init -backend-config ./deploy/live/${env}/${region}/${account}/${subenv}/backend.conf -reconfigure && terraform validate && terraform apply -var-file ./deploy/live/${env}/${region}/${account}/${subenv}/${subenv}.tfvars -auto-approve

.PHONY: tf-destroy-eks
tf-destroy-eks:
	export AWS_REGION=${region} && terraform init -backend-config ./deploy/live/${env}/${region}/${account}/${subenv}/backend.conf -reconfigure && terraform validate && terraform destroy -var-file ./deploy/live/${env}/${region}/${account}/${subenv}/${subenv}.tfvars -auto-approve
