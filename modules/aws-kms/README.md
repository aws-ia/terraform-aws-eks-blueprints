# AWS KMS module

Terraform module that creates an AWS KMS key and assigns it an alias, policy, and tags.

## Usage

```terraform
module "kms" {
  source = "./modules/aws-kms"

  alias                   = "alias/example"
  description             = "Example encryption key"
  policy                  = data.aws_iam_policy_document.key.json
  tags                    = local.tags
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
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | The waiting period, specified in number of days. After the waiting period ends, AWS KMS deletes the KMS key. If you specify a value, it must be between 7 and 30, inclusive. If you do not specify a value, it defaults to 30 | `number` | `30` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the key | `string` | n/a | yes |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Specifies whether annual key rotation is enabled | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid KMS key policy JSON document. Although this is a key policy, not an IAM policy, an aws\_iam\_policy\_document, in the form that designates a principal, can be used | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the object | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | The Amazon Resource Name (ARN) of the key. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The globally unique identifier for the key. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
