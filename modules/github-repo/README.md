# GitHub repository

# Introduction

Create a GitHub repository.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
<!-- | <a name="requirement_git"></a> [git](#requirement\_git) | >= 2.25.1 | -->

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 5.4.0 |

## Modules

No modules

## Resources

| Name | Type |
|------|------|
| [github_repository.repositories](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_repo_config"></a> [repo\_config](#input\_repo\_config) | Configurations of repositories that will be created | <pre>list(object({<br>    name        = string<br>    description = string<br>    visibility  = string<br>    template    = object({<br>      owner         = string<br>      template_repo = string<br>    })<br>}))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_url_list"></a> [url\_list](#output\_url\_list) | Repository url list |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
