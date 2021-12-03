# Fargate Profiles

# Introduction

The Fargate profile allows you to declare which pods run on Fargate for Amazon EKS Cluster. This declaration is done through the profile’s selectors. Each profile can have up to five selectors that contain a namespace and optional labels. You must define a namespace for every selector. The label field consists of multiple optional key-value pairs

## Fargate Profile Example
```hcl
  #---------------------------------------------------------#
  # FARGATE PROFILES
  #---------------------------------------------------------#

  fargate_profiles = {
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [{
        namespace = "default"
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          env         = "fargate"
        }
      }]

      subnet_ids = [] # Provide list of private subnets

      additional_tags = {
        ExtraTag = "Fargate"
      }
    },
    /*
    multi = {
      fargate_profile_name = "multi-namespaces"
      fargate_profile_namespaces = [{
        namespace = "default"
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          OS          = "Fargate"
          WorkerType  = "FARGATE"
          Namespace   = "default"
        }
        },
        {
          namespace = "sales"
          k8s_labels = {
            Environment = "preprod"
            Zone        = "dev"
            OS          = "Fargate"
            WorkerType  = "FARGATE"
            Namespace   = "default"
          }
      }]

      subnet_ids = [] # Provide list of private subnets

      additional_tags = {
        ExtraTag = "Fargate"
      }
    }, */
  } # END OF FARGATE PROFILES
```


<!--- BEGIN_TF_DOCS --->
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
| [aws_eks_fargate_profile.eks_fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_iam_policy.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.fargate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.fargate_pod_execution_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cwlogs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.fargate_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | EKS Cluster name | `string` | n/a | yes |
| <a name="input_fargate_profile"></a> [fargate\_profile](#input\_fargate\_profile) | Map of maps of `eks_node_groups` to create | `any` | `{}` | no |
| <a name="input_path"></a> [path](#input\_path) | IAM resource path, e.g. /dev/ | `string` | `"/"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_eks_fargate_profile_id"></a> [eks\_fargate\_profile\_id](#output\_eks\_fargate\_profile\_id) | EKS Cluster name and EKS Fargate Profile name separated by a colon |
| <a name="output_eks_fargate_profile_role_name"></a> [eks\_fargate\_profile\_role\_name](#output\_eks\_fargate\_profile\_role\_name) | Name of the EKS Fargate Profile IAM role |

<!--- END_TF_DOCS --->
