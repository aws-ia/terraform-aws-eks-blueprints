# AWS MWAA module

Terraform module to provision Amazon Managed Workflows for Apache Airflow (MWAA)

## Usage

```terraform
module "mwaa" {
  source                        = "../../modules/aws-mwaa"
  environment_name              = local.environment_name
  airflow_version               = local.airflow_version
  environment_class             = local.environment_class
  dag_s3_path                   = local.dag_s3_path
  plugins_s3_path               = local.plugins_s3_path
  requirements_s3_path          = local.requirements_s3_path
  logging_configuration         = local.logging_configuration
  airflow_configuration_options = local.airflow_configuration_options
  min_workers                   = local.airflow_min_workers
  max_workers                   = local.airflow_max_workers
  vpc_id                        = module.aws_vpc.vpc_id
  private_subnet_ids            = [module.aws_vpc.private_subnets[0], module.aws_vpc.private_subnets[1]]
  webserver_access_mode         = local.webserver_access_mode
  vpn_cidr = local.vpn_cidr
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias"></a> [alias](#input\_alias) | The display name of the alias. The name must start with the word 'alias' followed by a forward slash (alias/) | `string` | n/a | yes |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30. | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the key. | `string` | n/a | yes |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Specifies whether annual key rotation is enabled. | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid KMS key policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the object. | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The Amazon Resource Name (ARN) of the key. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique identifier for the key. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
