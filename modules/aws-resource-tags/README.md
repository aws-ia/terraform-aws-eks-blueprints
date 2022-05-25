<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | zone, e.g. 'prod', 'preprod' | `string` | n/a | yes |
| <a name="input_org"></a> [org](#input\_org) | tenant, which could be your organization name, e.g. aws' | `string` | `""` | no |
| <a name="input_resource"></a> [resource](#input\_resource) | Solution name, e.g. 'app' or 'cluster' | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Environment, e.g. 'load', 'zone', 'dev', 'uat' | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | aws resource id |
| <a name="output_tags"></a> [tags](#output\_tags) | aws resource tags |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
