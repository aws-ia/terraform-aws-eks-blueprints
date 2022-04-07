<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_codebuild_project.terraform_codebuild_project](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_project_source"></a> [build\_project\_source](#input\_build\_project\_source) | Information about the build output artifact location | `string` | n/a | yes |
| <a name="input_build_projects"></a> [build\_projects](#input\_build\_projects) | List of Names of the CodeBuild projects to be created | `list(string)` | n/a | yes |
| <a name="input_builder_compute_type"></a> [builder\_compute\_type](#input\_builder\_compute\_type) | Information about the compute resources the build project will use | `string` | n/a | yes |
| <a name="input_builder_image"></a> [builder\_image](#input\_builder\_image) | Docker image to use for the build project | `string` | n/a | yes |
| <a name="input_builder_image_pull_credentials_type"></a> [builder\_image\_pull\_credentials\_type](#input\_builder\_image\_pull\_credentials\_type) | Type of credentials AWS CodeBuild uses to pull images in your build. | `string` | n/a | yes |
| <a name="input_builder_type"></a> [builder\_type](#input\_builder\_type) | Type of build environment to use for related builds | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encryption | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Unique name for this project | `string` | n/a | yes |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | Codepipeline IAM role arn. | `string` | `""` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | Name of the S3 bucket used to store the deployment artifacts | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to the codebuild project | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | List of ARNs of the CodeBuild projects |
| <a name="output_id"></a> [id](#output\_id) | List of IDs of the CodeBuild projects |
| <a name="output_name"></a> [name](#output\_name) | List of Names of the CodeBuild projects |
<!-- END_TF_DOCS -->