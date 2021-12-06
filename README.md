# Amazon EKS SSP for Terraform

![GitHub](https://img.shields.io/github/license/aws-samples/aws-eks-accelerator-for-terraform)
[![e2e-test](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/e2e-test.yml/badge.svg)](https://github.com/aws-samples/aws-eks-accelerator-for-terraform/actions/workflows/e2e-test.yml)

> **Note**: EKS SSP for Terraform is in active development and should be considered a **pre-production** framework. Backwards incompatible Terraform changes are possible in future releases and support is best-effort by the EKS SSP community.

Welcome to the Amazon EKS Shared Services Platform (SSP) for Terraform.

This repository contains the source code for a Terraform framework that aims to accelerate the delivery of a batteries-included, multi-tenant container platform on top of Amazon EKS. This framework can be used by AWS customers, partners, and internal AWS teams to implement the foundational structure of a SSP according to AWS best practices and recommendations.

This project leverages the community [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks) modules for deploying EKS Clusters.

## Getting Started

The easiest way to get started with this framework is to follow our [Getting Started guide](./docs/getting-started.md).

## Documentation

For complete project documentation, please visit our [documentation directory](./docs).

## Patterns

To view examples for how you can leverage this framework, see the [deploy](./deploy) directory.

## Usage Example

The below demonstrates how you can leverage this framework to deploy an EKS cluster, a managed node group, and various Kubernetes add-ons.

```hcl
module "eks-ssp" {
    source = "git@github.com:aws-samples/aws-eks-accelerator-for-terraform.git"

    # EKS CLUSTER
    kubernetes_version       = "1.21"
    vpc_id             = "<vpcid>"     # Enter VPC ID
    private_subnet_ids = ["<subnet-a>", "<subnet-b>", "<subnet-c>"]     # Enter Private Subnet IDs

    # EKS MANAGED ADD-ON VARIABLES
    enable_vpc_cni_addon     = true
    enable_coredns_addon     = true
    enable_kube_proxy_addon  = true

    # KUBERNETES ADD-ON VARIABLES
    cluster_autoscaler_enable           = true
    metrics_server_enable               = true
    aws_lb_ingress_controller_enable    = true
    aws_for_fluentbit_enable           = true
    cert_manager_enable                 = true
    nginx_ingress_controller_enable     = true

    # EKS MANAGED NODE GROUPS
    managed_node_groups = {
        mg_m4l = {
            node_group_name = "managed-ondemand"
            instance_types  = ["m4.large"]
            subnet_ids      = ["<subnet-a>", "<subnet-b>", "<subnet-c>"]
        }
    }
}
```

The code above will provision the following:

✅  A new EKS Cluster with a managed node group.\
✅  EKS managed add-ons `vpc-cni`, `CoreDNS`, and `kube-proxy`.\
✅  `Cluster Autoscaler` and `Metrics Server` for scaling your workloads.\
✅  `Fluent Bit` for routing metrics.\
✅  `AWS Load Balancer Controller` for distributing traffic.\
✅  `cert-manager` for managing SSL/TLS certificates.\
✅  `Nginx` for managing ingress.

## Add-ons

This framework provides out of the box support for a wide range of popular Kubernetes add-ons. By default, the [Terraform Helm provider](https://github.com/hashicorp/terraform-provider-helm) is used to deploy add-ons with publicly available [Helm Charts](https://artifacthub.io/).
The framework provides support however for leveraging self-hosted Helm Chart as well.

For complete documentation on deploying add-ons, please visit our [add-on documentation](./docs/add-ons/index.md)

## Submodules

The root module calls into several submodules which provides support for deploying and integrating a number of external AWS services that can be used in concert with EKS. This included Amazon Managed Prometheus and EMR with EKS etc.

For complete documentation on deploying external services, please visit our submodules documentation.

## Motivation

The Amazon EKS SSP for Terraform allows customers to easily configure and deploy a multi-tenant, enterprise-ready container platform on top of EKS. With a large number of design choices, deploying production-grade container platform can take a significant about of time, involve integrating a wide range or AWS services and open source tools, and require deep understand of AWS and Kubernetes concepts.

This solution handles integrating EKS with popular open source and partner tools, in addition to AWS services, in order to allow customers to deploy a cohesive container platform that can be offered as a service to application teams. It provides out-of-the-box support for common operational tasks such as auto-scaling workloads, collecting logs and metrics from both clusters and running applications, managing ingress and egress, configuring network policy, managing secrets, deploying workloads via GitOps, and more. Customers can leverage the solution to deploy a container platform and start onboarding workloads in days, rather than months.

## Feedback

For architectural details, step-by-step instructions, and customization options, see our official documentation site.

To post feedback, submit feature ideas, or report bugs, use the Issues section of this GitHub repo.

To submit code for this Quick Start, see the AWS Quick Start Contributor's Kit.

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
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.6.1 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.1.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.66.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 2.4.1 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.6.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_agones"></a> [agones](#module\_agones) | ./kubernetes-addons/agones | n/a |
| <a name="module_argocd"></a> [argocd](#module\_argocd) | ./kubernetes-addons/argocd | n/a |
| <a name="module_aws_eks"></a> [aws\_eks](#module\_aws\_eks) | terraform-aws-modules/eks/aws | v17.20.0 |
| <a name="module_aws_eks_addon"></a> [aws\_eks\_addon](#module\_aws\_eks\_addon) | ./modules/aws-eks-addon | n/a |
| <a name="module_aws_eks_fargate_profiles"></a> [aws\_eks\_fargate\_profiles](#module\_aws\_eks\_fargate\_profiles) | ./modules/aws-eks-fargate-profiles | n/a |
| <a name="module_aws_eks_managed_node_groups"></a> [aws\_eks\_managed\_node\_groups](#module\_aws\_eks\_managed\_node\_groups) | ./modules/aws-eks-managed-node-groups | n/a |
| <a name="module_aws_eks_self_managed_node_groups"></a> [aws\_eks\_self\_managed\_node\_groups](#module\_aws\_eks\_self\_managed\_node\_groups) | ./modules/aws-eks-self-managed-node-groups | n/a |
| <a name="module_aws_for_fluent_bit"></a> [aws\_for\_fluent\_bit](#module\_aws\_for\_fluent\_bit) | ./kubernetes-addons/aws-for-fluentbit | n/a |
| <a name="module_aws_load_balancer_controller"></a> [aws\_load\_balancer\_controller](#module\_aws\_load\_balancer\_controller) | ./kubernetes-addons/aws-load-balancer-controller | n/a |
| <a name="module_aws_managed_prometheus"></a> [aws\_managed\_prometheus](#module\_aws\_managed\_prometheus) | ./modules/aws-managed-prometheus | n/a |
| <a name="module_aws_opentelemetry_collector"></a> [aws\_opentelemetry\_collector](#module\_aws\_opentelemetry\_collector) | ./kubernetes-addons/aws-opentelemetry-eks | n/a |
| <a name="module_cert_manager"></a> [cert\_manager](#module\_cert\_manager) | ./kubernetes-addons/cert-manager | n/a |
| <a name="module_cluster_autoscaler"></a> [cluster\_autoscaler](#module\_cluster\_autoscaler) | ./kubernetes-addons/cluster-autoscaler | n/a |
| <a name="module_eks_tags"></a> [eks\_tags](#module\_eks\_tags) | ./modules/aws-resource-tags | n/a |
| <a name="module_emr_on_eks"></a> [emr\_on\_eks](#module\_emr\_on\_eks) | ./modules/emr-on-eks | n/a |
| <a name="module_fargate_fluentbit"></a> [fargate\_fluentbit](#module\_fargate\_fluentbit) | ./kubernetes-addons/fargate-fluentbit | n/a |
| <a name="module_keda"></a> [keda](#module\_keda) | ./kubernetes-addons/keda | n/a |
| <a name="module_metrics_server"></a> [metrics\_server](#module\_metrics\_server) | ./kubernetes-addons/metrics-server | n/a |
| <a name="module_nginx_ingress"></a> [nginx\_ingress](#module\_nginx\_ingress) | ./kubernetes-addons/nginx-ingress | n/a |
| <a name="module_prometheus"></a> [prometheus](#module\_prometheus) | ./kubernetes-addons/prometheus | n/a |
| <a name="module_spark-k8s-operator"></a> [spark-k8s-operator](#module\_spark-k8s-operator) | ./kubernetes-addons/spark-k8s-operator | n/a |
| <a name="module_traefik_ingress"></a> [traefik\_ingress](#module\_traefik\_ingress) | ./kubernetes-addons/traefik-ingress | n/a |
| <a name="module_vpa"></a> [vpa](#module\_vpa) | ./kubernetes-addons/vertical-pod-autoscaler | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [kubernetes_config_map.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.eks_cluster_readiness](https://registry.terraform.io/providers/terraform-aws-modules/http/2.4.1/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agones_enable"></a> [agones\_enable](#input\_agones\_enable) | Enabling Agones Gaming Helm Chart | `bool` | `false` | no |
| <a name="input_agones_helm_chart"></a> [agones\_helm\_chart](#input\_agones\_helm\_chart) | Agones GameServer Helm chart config | `any` | `{}` | no |
| <a name="input_argocd_applications"></a> [argocd\_applications](#input\_argocd\_applications) | ARGO CD Applications config to bootstrap the cluster | `any` | `{}` | no |
| <a name="input_argocd_enable"></a> [argocd\_enable](#input\_argocd\_enable) | Enable ARGO CD Kubernetes Addon | `bool` | `false` | no |
| <a name="input_argocd_helm_chart"></a> [argocd\_helm\_chart](#input\_argocd\_helm\_chart) | ARGO CD Kubernetes Addon Configuration | `any` | `{}` | no |
| <a name="input_argocd_manage_add_ons"></a> [argocd\_manage\_add\_ons](#input\_argocd\_manage\_add\_ons) | Enables managing add-on configuration via ArgoCD | `bool` | `false` | no |
| <a name="input_aws_auth_additional_labels"></a> [aws\_auth\_additional\_labels](#input\_aws\_auth\_additional\_labels) | Additional kubernetes labels applied on aws-auth ConfigMap | `map(string)` | `{}` | no |
| <a name="input_aws_for_fluentbit_enable"></a> [aws\_for\_fluentbit\_enable](#input\_aws\_for\_fluentbit\_enable) | Enabling FluentBit Addon on EKS Worker Nodes | `bool` | `false` | no |
| <a name="input_aws_for_fluentbit_helm_chart"></a> [aws\_for\_fluentbit\_helm\_chart](#input\_aws\_for\_fluentbit\_helm\_chart) | Helm chart definition for aws\_for\_fluent\_bit | `any` | `{}` | no |
| <a name="input_aws_lb_ingress_controller_enable"></a> [aws\_lb\_ingress\_controller\_enable](#input\_aws\_lb\_ingress\_controller\_enable) | enabling LB Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_aws_lb_ingress_controller_helm_app"></a> [aws\_lb\_ingress\_controller\_helm\_app](#input\_aws\_lb\_ingress\_controller\_helm\_app) | Helm chart definition for aws\_lb\_ingress\_controller | `any` | `{}` | no |
| <a name="input_aws_managed_prometheus_enable"></a> [aws\_managed\_prometheus\_enable](#input\_aws\_managed\_prometheus\_enable) | Enable AWS Managed Prometheus service | `bool` | `false` | no |
| <a name="input_aws_managed_prometheus_workspace_name"></a> [aws\_managed\_prometheus\_workspace\_name](#input\_aws\_managed\_prometheus\_workspace\_name) | AWS Managed Prometheus WorkSpace Name | `string` | `"aws-managed-prometheus-workspace"` | no |
| <a name="input_aws_open_telemetry_addon"></a> [aws\_open\_telemetry\_addon](#input\_aws\_open\_telemetry\_addon) | AWS Open Telemetry Distro Addon Configuration | `any` | `{}` | no |
| <a name="input_aws_open_telemetry_enable"></a> [aws\_open\_telemetry\_enable](#input\_aws\_open\_telemetry\_enable) | Enable AWS Open Telemetry Distro Addon | `bool` | `false` | no |
| <a name="input_cert_manager_enable"></a> [cert\_manager\_enable](#input\_cert\_manager\_enable) | Enabling Cert Manager Helm Chart installation. | `bool` | `false` | no |
| <a name="input_cert_manager_helm_chart"></a> [cert\_manager\_helm\_chart](#input\_cert\_manager\_helm\_chart) | Cert Manager Helm chart configuration | `any` | `{}` | no |
| <a name="input_cluster_autoscaler_enable"></a> [cluster\_autoscaler\_enable](#input\_cluster\_autoscaler\_enable) | Enabling Cluster autoscaler on eks cluster | `bool` | `false` | no |
| <a name="input_cluster_autoscaler_helm_chart"></a> [cluster\_autoscaler\_helm\_chart](#input\_cluster\_autoscaler\_helm\_chart) | Cluster Autoscaler Helm Chart Config | `any` | `{}` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster\_enabled\_log\_types](#input\_cluster\_enabled\_log\_types) | A list of the desired control plane logging to enable | `list(string)` | <pre>[<br>  "api",<br>  "audit",<br>  "authenticator",<br>  "controllerManager",<br>  "scheduler"<br>]</pre> | no |
| <a name="input_cluster_endpoint_private_access"></a> [cluster\_endpoint\_private\_access](#input\_cluster\_endpoint\_private\_access) | Indicates whether or not the Amazon EKS private API server endpoint is enabled. Default to AWS EKS resource and it is false | `bool` | `false` | no |
| <a name="input_cluster_endpoint_public_access"></a> [cluster\_endpoint\_public\_access](#input\_cluster\_endpoint\_public\_access) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_cluster_log_retention_period"></a> [cluster\_log\_retention\_period](#input\_cluster\_log\_retention\_period) | Number of days to retain cluster logs | `number` | `7` | no |
| <a name="input_coredns_addon_version"></a> [coredns\_addon\_version](#input\_coredns\_addon\_version) | CoreDNS Addon version | `string` | `"v1.8.3-eksbuild.1"` | no |
| <a name="input_create_eks"></a> [create\_eks](#input\_create\_eks) | Enable Create EKS | `bool` | `false` | no |
| <a name="input_emr_on_eks_teams"></a> [emr\_on\_eks\_teams](#input\_emr\_on\_eks\_teams) | EMR on EKS Teams configuration | `any` | `{}` | no |
| <a name="input_enable_coredns_addon"></a> [enable\_coredns\_addon](#input\_enable\_coredns\_addon) | Enable CoreDNS Addon | `bool` | `false` | no |
| <a name="input_enable_emr_on_eks"></a> [enable\_emr\_on\_eks](#input\_enable\_emr\_on\_eks) | Enabling EMR on EKS Config | `bool` | `false` | no |
| <a name="input_enable_irsa"></a> [enable\_irsa](#input\_enable\_irsa) | Indicates whether or not the Amazon EKS public API server endpoint is enabled. Default to AWS EKS resource and it is true | `bool` | `true` | no |
| <a name="input_enable_kube_proxy_addon"></a> [enable\_kube\_proxy\_addon](#input\_enable\_kube\_proxy\_addon) | Enable Kube Proxy Addon | `bool` | `false` | no |
| <a name="input_enable_vpc_cni_addon"></a> [enable\_vpc\_cni\_addon](#input\_enable\_vpc\_cni\_addon) | Enable VPC CNI Addon | `bool` | `false` | no |
| <a name="input_enable_windows_support"></a> [enable\_windows\_support](#input\_enable\_windows\_support) | Enable Windows support | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment area, e.g. prod or preprod | `string` | `"preprod"` | no |
| <a name="input_fargate_fluentbit_config"></a> [fargate\_fluentbit\_config](#input\_fargate\_fluentbit\_config) | Fargate fluentbit configuration | `any` | `{}` | no |
| <a name="input_fargate_fluentbit_enable"></a> [fargate\_fluentbit\_enable](#input\_fargate\_fluentbit\_enable) | Enabling fargate\_fluent\_bit module on eks cluster | `bool` | `false` | no |
| <a name="input_fargate_profiles"></a> [fargate\_profiles](#input\_fargate\_profiles) | Fargate Profile configuration | `any` | `{}` | no |
| <a name="input_keda_create_irsa"></a> [keda\_create\_irsa](#input\_keda\_create\_irsa) | Indicates if the add-on should create a IAM role + service account | `bool` | `true` | no |
| <a name="input_keda_enable"></a> [keda\_enable](#input\_keda\_enable) | Enable KEDA Event-based autoscaler for workloads on Kubernetes | `bool` | `false` | no |
| <a name="input_keda_helm_chart"></a> [keda\_helm\_chart](#input\_keda\_helm\_chart) | KEDA Event-based autoscaler Kubernetes Addon Configuration | `any` | `{}` | no |
| <a name="input_keda_irsa_policies"></a> [keda\_irsa\_policies](#input\_keda\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_kube_proxy_addon_version"></a> [kube\_proxy\_addon\_version](#input\_kube\_proxy\_addon\_version) | KubeProxy Addon version | `string` | `"v1.20.4-eksbuild.2"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Desired Kubernetes master version. If you do not specify a value, the latest available version is used | `string` | `"1.21"` | no |
| <a name="input_managed_node_groups"></a> [managed\_node\_groups](#input\_managed\_node\_groups) | Managed Node groups configuration | `any` | `{}` | no |
| <a name="input_map_accounts"></a> [map\_accounts](#input\_map\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_map_roles"></a> [map\_roles](#input\_map\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_map_users"></a> [map\_users](#input\_map\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_metrics_server_enable"></a> [metrics\_server\_enable](#input\_metrics\_server\_enable) | Enabling metrics server on eks cluster | `bool` | `false` | no |
| <a name="input_metrics_server_helm_chart"></a> [metrics\_server\_helm\_chart](#input\_metrics\_server\_helm\_chart) | Metrics Server Helm Addon Config | `any` | `{}` | no |
| <a name="input_nginx_helm_chart"></a> [nginx\_helm\_chart](#input\_nginx\_helm\_chart) | NGINX Ingress Controller Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_nginx_ingress_controller_enable"></a> [nginx\_ingress\_controller\_enable](#input\_nginx\_ingress\_controller\_enable) | Enabling NGINX Ingress Controller on EKS Cluster | `bool` | `false` | no |
| <a name="input_org"></a> [org](#input\_org) | tenant, which could be your organization name, e.g. aws' | `string` | `""` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list(string)` | n/a | yes |
| <a name="input_prometheus_enable"></a> [prometheus\_enable](#input\_prometheus\_enable) | Enable Community Prometheus Helm Addon | `bool` | `false` | no |
| <a name="input_prometheus_helm_chart"></a> [prometheus\_helm\_chart](#input\_prometheus\_helm\_chart) | Community Prometheus Helm Addon Config | `any` | `{}` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | list of private subnets Id's for the Worker nodes | `list(string)` | `[]` | no |
| <a name="input_self_managed_node_groups"></a> [self\_managed\_node\_groups](#input\_self\_managed\_node\_groups) | Self-Managed Node groups configuration | `any` | `{}` | no |
| <a name="input_spark_on_k8s_operator_enable"></a> [spark\_on\_k8s\_operator\_enable](#input\_spark\_on\_k8s\_operator\_enable) | Enabling Spark on K8s Operator on EKS Cluster | `bool` | `false` | no |
| <a name="input_spark_on_k8s_operator_helm_chart"></a> [spark\_on\_k8s\_operator\_helm\_chart](#input\_spark\_on\_k8s\_operator\_helm\_chart) | Spark on K8s Operator Helm Chart Configuration | `any` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Account Name or unique account unique id e.g., apps or management or aws007 | `string` | `"aws"` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Terraform Version | `string` | `"Terraform"` | no |
| <a name="input_traefik_helm_chart"></a> [traefik\_helm\_chart](#input\_traefik\_helm\_chart) | Traefik Helm Addon Config | `any` | `{}` | no |
| <a name="input_traefik_ingress_controller_enable"></a> [traefik\_ingress\_controller\_enable](#input\_traefik\_ingress\_controller\_enable) | Enabling Traefik Ingress Controller on eks cluster | `bool` | `false` | no |
| <a name="input_vpa_enable"></a> [vpa\_enable](#input\_vpa\_enable) | Enable Kubernetes Vertical Pod Autoscaler | `bool` | `false` | no |
| <a name="input_vpa_helm_chart"></a> [vpa\_helm\_chart](#input\_vpa\_helm\_chart) | Kubernetes Vertical Pod Autoscaler Helm chart config | `any` | `{}` | no |
| <a name="input_vpc_cni_addon_version"></a> [vpc\_cni\_addon\_version](#input\_vpc\_cni\_addon\_version) | VPC CNI Addon version | `string` | `"v1.8.0-eksbuild.1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | zone, e.g. dev or qa or load or ops etc... | `string` | `"dev"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_amp_work_arn"></a> [amp\_work\_arn](#output\_amp\_work\_arn) | AWS Managed Prometheus workspace ARN |
| <a name="output_amp_work_id"></a> [amp\_work\_id](#output\_amp\_work\_id) | AWS Managed Prometheus workspace id |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Kubernetes Cluster Name |
| <a name="output_cluster_oidc_url"></a> [cluster\_oidc\_url](#output\_cluster\_oidc\_url) | The URL on the EKS cluster OIDC Issuer |
| <a name="output_cluster_primary_security_group_id"></a> [cluster\_primary\_security\_group\_id](#output\_cluster\_primary\_security\_group\_id) | EKS Cluster Security group ID |
| <a name="output_cluster_security_group_id"></a> [cluster\_security\_group\_id](#output\_cluster\_security\_group\_id) | EKS Control Plane Security Group ID |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
| <a name="output_emr_on_eks_role_arn"></a> [emr\_on\_eks\_role\_arn](#output\_emr\_on\_eks\_role\_arn) | IAM execution role ARN for EMR on EKS |
| <a name="output_emr_on_eks_role_id"></a> [emr\_on\_eks\_role\_id](#output\_emr\_on\_eks\_role\_id) | IAM execution role ID for EMR on EKS |
| <a name="output_fargate_profiles"></a> [fargate\_profiles](#output\_fargate\_profiles) | Outputs from EKS Fargate profiles groups |
| <a name="output_fargate_profiles_aws_auth_config_map"></a> [fargate\_profiles\_aws\_auth\_config\_map](#output\_fargate\_profiles\_aws\_auth\_config\_map) | Fargate profiles AWS auth map |
| <a name="output_fargate_profiles_iam_role_arns"></a> [fargate\_profiles\_iam\_role\_arns](#output\_fargate\_profiles\_iam\_role\_arns) | IAM role arn's for Fargate Profiles |
| <a name="output_managed_node_group_aws_auth_config_map"></a> [managed\_node\_group\_aws\_auth\_config\_map](#output\_managed\_node\_group\_aws\_auth\_config\_map) | Managed node groups AWS auth map |
| <a name="output_managed_node_group_iam_role_arns"></a> [managed\_node\_group\_iam\_role\_arns](#output\_managed\_node\_group\_iam\_role\_arns) | IAM role arn's of managed node groups |
| <a name="output_managed_node_groups"></a> [managed\_node\_groups](#output\_managed\_node\_groups) | Outputs from EKS Managed node groups |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | The ARN of the OIDC Provider if `enable_irsa = true`. |
| <a name="output_self_managed_node_group_aws_auth_config_map"></a> [self\_managed\_node\_group\_aws\_auth\_config\_map](#output\_self\_managed\_node\_group\_aws\_auth\_config\_map) | Self managed node groups AWS auth map |
| <a name="output_self_managed_node_group_iam_role_arns"></a> [self\_managed\_node\_group\_iam\_role\_arns](#output\_self\_managed\_node\_group\_iam\_role\_arns) | IAM role arn's of self managed node groups |
| <a name="output_self_managed_node_groups"></a> [self\_managed\_node\_groups](#output\_self\_managed\_node\_groups) | Outputs from EKS Self-managed node groups |
| <a name="output_windows_node_group_aws_auth_config_map"></a> [windows\_node\_group\_aws\_auth\_config\_map](#output\_windows\_node\_group\_aws\_auth\_config\_map) | Windows node groups AWS auth map |
| <a name="output_worker_security_group_id"></a> [worker\_security\_group\_id](#output\_worker\_security\_group\_id) | EKS Worker Security group ID created by EKS module |

<!--- END_TF_DOCS --->

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
