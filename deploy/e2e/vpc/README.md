## How to deploy the example

    git clone https://github.com/aws-samples/aws-eks-accelerator-for-terraform.git

    cd ~/aws-eks-accelerator-for-terraform/deploy/e2e/vpc

    terraform init -backend-config backend.conf -reconfigure

    terraform plan -var-file base.tfvars

    terraform apply -var-file base.tfvars -auto-approve


## How to Destroy the cluster

    terraform destroy -var-file base.tfvars -auto-approve  


<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks-cluster-with-import-vpc"></a> [eks-cluster-with-import-vpc](#module\_eks-cluster-with-import-vpc) | ../../../examples/eks-cluster-with-import-vpc/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | Kubernetes Version | `string` | `"1.21"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of IDs of private subnets |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of IDs of public subnets |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |

<!--- END_TF_DOCS --->
