# Amazon EKS SSP for Terraform

![GitHub](https://img.shields.io/github/license/aws-samples/aws-eks-accelerator-for-terraform)
[![e2e-test](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/e2e-test.yml/badge.svg)](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/e2e-test.yml)
[![terrascan](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/terrascan.yml/badge.svg)](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/terrascan.yml)
[![tfsec](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/tfsec-analysis.yml/badge.svg)](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/tfsec-analysis.yml)
[![kics-security-scan](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/kics-security-scan.yml/badge.svg)](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/kics-security-scan.yml)

> **Note**: EKS SSP for Terraform is in active development and should be considered a **pre-production** framework. Backwards incompatible Terraform changes are possible in future releases and support is best-effort by the EKS SSP community.

Welcome to the Amazon EKS Shared Services Platform (SSP) for Terraform.

This repository contains the source code for a Terraform framework that aims to accelerate the delivery of a batteries-included, multi-tenant container platform on top of Amazon EKS. This framework can be used by AWS customers, partners, and internal AWS teams to implement the foundational structure of a SSP according to AWS best practices and recommendations.

This project leverages the community [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) modules for deploying EKS Clusters.

## Getting Started
The easiest way to get started with this framework is to follow our [Getting Started guide](./docs/getting-started.md).

## Documentation
For complete project documentation, please visit our [documentation directory](./docs).

## Patterns
To view examples for how you can leverage this framework, see the [examples](./examples) directory.

## Usage Example
The below demonstrates how you can leverage this framework to deploy an EKS cluster, a managed node group, and various Kubernetes add-ons.

```hcl
module "eks-ssp" {
    source = "github.com/aws-samples/aws-eks-accelerator-for-terraform"

    # EKS CLUSTER
    kubernetes_version        = "1.21"
    vpc_id                    = "<vpcid>"                                      # Enter VPC ID
    private_subnet_ids        = ["<subnet-a>", "<subnet-b>", "<subnet-c>"]     # Enter Private Subnet IDs

  # EKS MANAGED NODE GROUPS
    managed_node_groups = {
      mg_m4l = {
        node_group_name = "managed-ondemand"
        instance_types  = ["m4.large"]
        subnet_ids      = ["<subnet-a>", "<subnet-b>", "<subnet-c>"]
      }
    }
}

#--------------------------------------------
# Deploy Kubernetes Add-ons with sub module
#--------------------------------------------
module "eks-ssp-kubernetes-addons" {
    source = "github.com/aws-samples/aws-eks-accelerator-for-terraform//modules/kubernetes-addons"

    eks_cluster_id                        = module.eks-ssp.eks_cluster_id

    # EKS Addons
    enable_amazon_eks_vpc_cni             = true
    enable_amazon_eks_coredns             = true
    enable_amazon_eks_kube_proxy          = true
    enable_amazon_eks_aws_ebs_csi_driver  = true

    #K8s Add-ons
    enable_aws_load_balancer_controller   = true
    enable_metrics_server                 = true
    enable_cluster_autoscaler             = true
    enable_aws_for_fluentbit              = true
    enable_argocd                         = true
    enable_ingress_nginx                  = true

    depends_on = [module.eks-ssp.managed_node_groups]
}
```

The code above will provision the following:

✅  A new EKS Cluster with a managed node group.\
✅  Amazon EKS add-ons `vpc-cni`, `CoreDNS`, `kube-proxy`, and `aws-ebs-csi-driver`.\
✅  `Cluster Autoscaler` and `Metrics Server` for scaling your workloads.\
✅  `Fluent Bit` for routing logs.\
✅  `AWS Load Balancer Controller` for distributing traffic.\
✅  `Argocd` for declarative GitOps CD for Kubernetes.\
✅  `Nginx` for managing ingress.

## Add-ons
This framework provides out of the box support for a wide range of popular Kubernetes add-ons.
By default, the [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy add-ons with publicly available [Helm Charts](https://artifacthub.io/).
The framework provides support for leveraging self-hosted Helm Chart as well.

For complete documentation on deploying add-ons, please visit our [add-on documentation](./docs/add-ons/index.md)

## Submodules
The root module calls into several submodules which provides support for deploying and integrating a number of external AWS services that can be used in concert with Amazon EKS.
This included Amazon Managed Prometheus and EMR with EKS etc.
For complete documentation on deploying external services, please visit our submodules documentation.

## Motivation
The Amazon EKS SSP for Terraform allows customers to easily configure and deploy a multi-tenant, enterprise-ready container platform on top of EKS.
With a large number of design choices, deploying production-grade container platform can take a significant amount of time, involve integrating a wide range or AWS services and open source tools, and require deep understand of AWS and Kubernetes concepts.
This solution handles integrating EKS with popular open source and partner tools, in addition to AWS services, in order to allow customers to deploy a cohesive container platform that can be offered as a service to application teams.
It provides out-of-the-box support for common operational tasks such as auto-scaling workloads, collecting logs and metrics from both clusters and running applications, managing ingress and egress, configuring network policy, managing secrets, deploying workloads via GitOps, and more.
Customers can leverage the solution to deploy a container platform and start onboarding workloads in days, rather than months.

## Feedback

For architectural details, step-by-step instructions, and customization options, see our official documentation site.

To post feedback, submit feature ideas, or report bugs, use the Issues section of this GitHub repo.

To submit code for this Quick Start, see the AWS Quick Start [Contributor's guide](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/blob/main/CONTRIBUTING.md).

---
<!--- BEGIN_TF_DOCS --->
Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
SPDX-License-Identifier: MIT-0

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.66.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.4.1 |
| <a name="requirement_http"></a> [http](#requirement\_http) | 2.4.1 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.7.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.4.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.7.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_eks"></a> [aws\_eks](#module\_aws\_eks) | terraform-aws-modules/eks/aws | v17.20.0 |
| <a name="module_aws_eks_fargate_profiles"></a> [aws\_eks\_fargate\_profiles](#module\_aws\_eks\_fargate\_profiles) | ./modules/aws-eks-fargate-profiles | n/a |
| <a name="module_aws_eks_managed_node_groups"></a> [aws\_eks\_managed\_node\_groups](#module\_aws\_eks\_managed\_node\_groups) | ./modules/aws-eks-managed-node-groups | n/a |
| <a name="module_aws_eks_self_managed_node_groups"></a> [aws\_eks\_self\_managed\_node\_groups](#module\_aws\_eks\_self\_managed\_node\_groups) | ./modules/aws-eks-self-managed-node-groups | n/a |
| <a name="module_aws_eks_teams"></a> [aws\_eks\_teams](#module\_aws\_eks\_teams) | ./modules/aws-eks-teams | n/a |
| <a name="module_aws_managed_prometheus"></a> [aws\_managed\_prometheus](#module\_aws\_managed\_prometheus) | ./modules/aws-managed-prometheus | n/a |
| <a name="module_eks_tags"></a> [eks\_tags](#module\_eks\_tags) | ./modules/aws-resource-tags | n/a |
| <a name="module_emr_on_eks"></a> [emr\_on\_eks](#module\_emr\_on\_eks) | ./modules/emr-on-eks | n/a |
| <a name="module_kms"></a> [kms](#module\_kms) | ./modules/aws-kms | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_config_map.amazon_vpc_cni](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.eks_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.eks_cluster_readiness](https://registry.terraform.io/providers/terraform-aws-modules/http/2.4.1/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_prometheus_workspace_alias"></a> [amazon\_prometheus\_workspace\_alias](#input\_amazon\_prometheus\_workspace\_alias) | AWS Managed Prometheus WorkSpace Name | `string` | `null` | no |
| <a name="input_application_teams"></a> [application\_teams](#input\_application\_teams) | Map of maps of Application Teams to create | `any` | `{}` | no |
| <a name="input_aws_auth_additional_labels"></a> [aws\_auth\_additional\_labels](#input\_aws\_auth\_additional\_labels) | Additional kubernetes labels applied on aws-auth ConfigMap | `map(string)` | `{}` | no |
| <a name="input_cluster_create_endpoint_private_access_sg_rule"></a> [cluster\_create\_endpoint\_private\_access\_sg\_rule](#input\_cluster\_create\_endpoint\_private\_access\_sg\_rule) | Whether to create security group rules for the access to the Amazon EKS private API server endpoint | `bool` | `false` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the EKS private API server endpoint is enabled. Default to EKS resource and it is false | `bool` | `false` | no |
| <a name="input_cluster_endpoint_private_access_cidrs"></a> [cluster\_endpoint\_private\_access\_cidrs](#input\_cluster\_endpoint\_private\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS private API server endpoint | `list(string)` | `[]` | no |
| <a name="input_cluster_endpoint_private_access_sg"></a> [cluster\_endpoint\_private\_access\_sg](#input\_cluster\_endpoint\_private\_access\_sg) | List of security group IDs which can access the Amazon EKS private API server endpoint | `list(string)` | `[]` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the EKS public API server endpoint is enabled. Default to EKS resource and it is true | `bool` | `true` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | List of CIDR blocks which can access the Amazon EKS public API server endpoint | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_kms_key_arn"></a> [cluster\_kms\_key\_arn](#input\_cluster\_kms\_key\_arn) | A valid EKS Cluster KMS Key ARN to encrypt Kubernetes secrets | `string` | `null` | no |
| <a name="input_cluster_kms_key_deletion_window_in_days"></a> [cluster\_kms\_key\_deletion\_window\_in\_days](#input\_cluster\_kms\_key\_deletion\_window\_in\_days) | The waiting period, specified in number of days (7 - 30). After the waiting period ends, AWS KMS deletes the KMS key | `number` | `30` | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster\_log\_retention\_in\_days](#input\_cluster\_log\_retention\_in\_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs | `number` | `7` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster Name | `string` | `""` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Create EKS cluster | `bool` | `true` | no |
| <a name="input_emr_on_eks_teams"></a> [emr\_on\_eks\_teams](#input\_emr\_on\_eks\_teams) | EMR on EKS Teams config | `any` | `{}` | no |
| <a name="input_enable_amazon_prometheus"></a> [enable\_amazon\_prometheus](#input\_enable\_amazon\_prometheus) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_enable_emr_on_eks"></a> [enable\_emr\_on\_eks](#input\_enable\_emr\_on\_eks) | Enable EMR on EKS | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Enable IAM Roles for Service Accounts | `bool` | `true` | no |
| <a name="input_enable_windows_support"></a> [enable\_windows\_support](#input\_enable\_windows\_support) | Enable Windows support | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate profile configuration | `any` | `{}` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Desired kubernetes version. If you do not specify a value, the latest available version is used | `string` | `"1.21"` | no |
| <a name="input_managed_node_groups"></a> [managed\_node\_groups](#input\_managed\_node\_groups) | Managed node groups configuration | `any` | `{}` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth ConfigMap | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth ConfigMap | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth ConfigMap | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_org"></a> [org](#input\_org) | tenant, which could be your organization name, e.g. aws' | `string` | `""` | no |
| <a name="input_platform_teams"></a> [platform\_teams](#input\_platform\_teams) | Map of maps of platform teams to create | `any` | `{}` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | List of private subnets Ids for the worker nodes | `list(string)` | n/a | yes |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | List of public subnets Ids for the worker nodes | `list(string)` | `[]` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Self-managed node groups configuration | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws"` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform version | `string` | `"Terraform"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC Id | `string` | n/a | yes |
| <a name="input_worker_additional_security_group_ids"></a> [worker\_additional\_security\_group\_ids](#input\_worker\_additional\_security\_group\_ids) | A list of additional security group ids to attach to worker instances | `list(string)` | `[]` | no |
| <a name="input_worker_create_security_group"></a> [worker\_create\_security\_group](#input\_worker\_create\_security\_group) | Whether to create a security group for the workers or attach the workers to `worker_security_group_id`. | `bool` | `true` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amazon_prometheus_workspace_endpoint"></a> [amazon\_prometheus\_workspace\_endpoint](#output\_amazon\_prometheus\_workspace\_endpoint) | Amazon Managed Prometheus Workspace Endpoint |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | EKS Cluster Security group ID |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS Control Plane Security Group ID |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_eks_cluster_id"></a> [eks\_cluster\_id](#output\_eks\_cluster\_id) | Kubernetes Cluster Name |
| <a name="output_eks_oidc_issuer_url"></a> [eks\_oidc\_issuer\_url](#output\_eks\_oidc\_issuer\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_eks_oidc_provider_arn"></a> [eks\_oidc\_provider\_arn](#output\_eks\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. |
| <a name="output_emr_on_eks_role_arn"></a> [emr\_on\_eks\_role\_arn](#output\_emr\_on\_eks\_role\_arn) | IAM execution role ARN for EMR on EKS |
| <a name="output_emr_on_eks_role_id"></a> [emr\_on\_eks\_role\_id](#output\_emr\_on\_eks\_role\_id) | IAM execution role ID for EMR on EKS |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Outputs from EKS Fargate profiles groups |
| <a name="output_fargate_profiles_aws_auth_config_map"></a> [fargate\_profiles\_aws\_auth\_config\_map](#output\_fargate\_profiles\_aws\_auth\_config\_map) | Fargate profiles AWS auth map |
| <a name="output_fargate_profiles_iam_role_arns"></a> [fargate\_profiles\_iam\_role\_arns](#output\_fargate\_profiles\_iam\_role\_arns) | IAM role arn's for Fargate Profiles |
| <a name="output_managed_node_group_aws_auth_config_map"></a> [managed\_node\_group\_aws\_auth\_config\_map](#output\_managed\_node\_group\_aws\_auth\_config\_map) | Managed node groups AWS auth map |
| <a name="output_managed_node_group_iam_instance_profile_arns"></a> [managed\_node\_group\_iam\_instance\_profile\_arns](#output\_managed\_node\_group\_iam\_instance\_profile\_arns) | IAM instance profile arn's of managed node groups |
| <a name="output_managed_node_group_iam_instance_profile_id"></a> [managed\_node\_group\_iam\_instance\_profile\_id](#output\_managed\_node\_group\_iam\_instance\_profile\_id) | IAM instance profile id of managed node groups |
| <a name="output_managed_node_group_iam_role_arns"></a> [managed\_node\_group\_iam\_role\_arns](#output\_managed\_node\_group\_iam\_role\_arns) | IAM role arn's of managed node groups |
| <a name="output_managed_node_groups"></a> [managed\_node\_groups](#output\_managed\_node\_groups) | Outputs from EKS Managed node groups |
| <a name="output_self_managed_node_group_autoscaling_groups"></a> [self\_managed\_node\_group\_autoscaling\_groups](#output\_self\_managed\_node\_group\_autoscaling\_groups) | Autoscaling group names of self managed node groups |
| <a name="output_self_managed_node_group_aws_auth_config_map"></a> [self\_managed\_node\_group\_aws\_auth\_config\_map](#output\_self\_managed\_node\_group\_aws\_auth\_config\_map) | Self managed node groups AWS auth map |
| <a name="output_self_managed_node_group_iam_instance_profile_id"></a> [self\_managed\_node\_group\_iam\_instance\_profile\_id](#output\_self\_managed\_node\_group\_iam\_instance\_profile\_id) | IAM instance profile id of managed node groups |
| <a name="output_self_managed_node_group_iam_role_arns"></a> [self\_managed\_node\_group\_iam\_role\_arns](#output\_self\_managed\_node\_group\_iam\_role\_arns) | IAM role arn's of self managed node groups |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Outputs from EKS Self-managed node groups |
| <a name="output_teams"></a> [teams](#output\_teams) | Outputs from EKS Fargate profiles groups |
| <a name="output_windows_node_group_aws_auth_config_map"></a> [windows\_node\_group\_aws\_auth\_config\_map](#output\_windows\_node\_group\_aws\_auth\_config\_map) | Windows node groups AWS auth map |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | EKS Worker Security group ID created by EKS module |

<!--- END_TF_DOCS --->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
