#!/bin/bash

# Dependecies
HOMEBREW_LIBS :=  terraform

#------------------------------------------------------------------------------
# PR TEST
#------------------------------------------------------------------------------

pr-test: 
	make terraform-fmt
	make terraform-init
	make terraform-validate
	make terraform-plan

terraform-fmt:
	terraform fmt -check -diff -recursive -list -no-color

terraform-init:
	cd test/pr && \
	terraform init --reconfigure

terraform-validate: 
	cd test/pr && \
	terraform validate -no-color

terraform-plan: 
	cd test/pr && \
	terraform plan -no-color

mkdocs:
	mkdocs serve 

push-mkdocs:
	mkdocs gh-deploy

bootstrap:
	@for LIB in $(HOMEBREW_LIBS) ; do \
		LIB=$$LIB make check-lib ; \
    done

check-lib:
ifeq ($(shell brew ls --versions $(LIB)),)
	@echo Installing $(LIB) via Hombrew
	@brew install $(LIB)
else
	@echo $(LIB) is already installed, skipping.
endif
