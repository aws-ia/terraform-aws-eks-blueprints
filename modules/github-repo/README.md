# GitHub repository

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_git"></a> [github](#requirement\_git) | >= 5.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | >= 5.4.0 |

## Modules

No modules

## Resources

| Name | Type |
|------|------|
| [github_repository.loosely_coupled](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository.tightly_coupled](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the GitHub repository that will be created. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | The description of the GitHub repository that will be created. | `string` | `""` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | The visibility of the GitHub repository that will be created. | `string` | `"public"` | no |
| <a name="input_template_owner"></a> [template_owner](#input\_template_owner) | GitHub template repository name. (Default: provider_owner) | `string` | `""` | no |
| <a name="input_template_repo_name"></a> [template_repo_name](#input\_template_repo_name) | GitHub template repository name. (Will not use a template, if not set) | `string` | `""` | no |
| <a name="input_provider_owner"></a> [provider_owner](#input\_provider_owner) | Github provider account/organisation. | `string` | n/a | yes |
| <a name="input_provider_token"></a> [provider_token](#input\_provider_token) | Github provider token. | `string` | n/a | yes |
| <a name="input_loose_coupling"></a> [loose_coupling](#input\_loose_coupling) | If true, the repository will not be delited on 'terraform destory'. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_repository"></a> [created_repository](#output\_created\_repository) | The github repository that had been created. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
