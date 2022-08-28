# Frequently Asked Questions

## Timeouts on destroy

Customers who are deleting their environments using `terraform destroy` may see timeout errors when VPCs are being deleted. This is due to a known issue in the [vpc-cni](https://github.com/aws/amazon-vpc-cni-k8s/issues/1223#issue-704536542)

Customers may face a situation where ENIs that were attached to EKS managed nodes (same may apply to self-managed nodes) are not being deleted by the VPC CNI as expected which leads to IaC tool failures, such as:

* ENIs are left on subnets
* EKS managed security group which is attached to the ENI can’t be deleted by EKS

The current recommendation is to execute cleanup in the following order:

1. delete all pods that have been created in the cluster.
2. add delay/ wait
3. delete VPC CNI
4. delete nodes
5. delete cluster

## Leaked CloudWatch Logs Group

Sometimes, customers may see the CloudWatch Log Group for EKS cluster being created is left behind after their blueprint has been destroyed using `terraform destroy`. This happens because even after terraform deletes the CW log group, there’s still logs being processed behind the scene by AWS EKS and service continues to write logs after recreating the log group using the EKS service IAM role which users don't have control over. This results in a terraform failure when the same blueprint is being recreated due to the existing log group left behind.

There are two options here:

1. During cluster creation set `var.create_cloudwatch_log_group` to `false` (default behavior). This will indicate to the upstream [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/main.tf#L70) to not create the log group, but instead let the service create the log group. This means that upon cluster deletion the log group will be left behind but there will not be terraform failures if you re-create the same cluster as terraform does not manage the log group creation/deletion anymore.

2. During cluster creation set `var.create_cloudwatch_log_group` to `true`. This will indicate to the upstream [terraform-aws-eks](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/main.tf#L70) to create the log group via terraform. EKS service will detect the log group and will start forwarding the logs for the log types [enabled](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/6d7245621f97bb8e38642a9e40ddce3a32ff9efb/variables.tf#L35). Upon deletion terraform will delete the log group but depending upon any unforwarded logs, the EKS service may recreate log group using the service role. This will result in terraform errors if the same blueprint is recreated. To proceed, manually delete the log group using the console or cli rerun the `terraform apply`.

## Provider Authentication

The chain of events when provisioning an example is typically in the stages of VPC -> EKS cluster -> addons and manifests. Per Terraform's recommendation, it is not recommended to pass an unknown value into provider configurations. However, for the sake of simplicity and ease of use, Blueprints does specify the AWS provider along with the Kubernetes, Helm, and Kubectl providers in order to show the full configuration requred for provisioning example. Note - this is the configuration *required* to provision the example, not necessarily the shape of how the configuration should be structured; users are encouraged to split up EKS cluster creation from addon and manifest provisioning to align with Terraform's recommendations.

With that said, the examples here are combining the providers and users can sometimes encounter various issues with the provider authentication methods. There are primarily two methods for authenticating the Kubernetes, Helm, and Kubectl providers to the EKS cluster created:

1. Using a static token which has a lifetime of 15 minutes per the EKS service documentation.
2. Using the `exec()` method which will fetch a token at the time of Terraform invocation.

The Kubernetes and Helm providers [recommend the `exec()` method](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins), however this has the caveat that it requires the awscli to be installed on the machine running Terraform *AND* of at least a minimum version to support the API spec used by the provider (i.e. - `"client.authentication.k8s.io/v1alpha1"`, `"client.authentication.k8s.io/v1beta1"`, etc.). Selecting the appropriate provider authentication method is left up to users, and the examples used in this project will default to using the static token method for ease of use.

Users of the static token method should be aware that if they receive a `401 Unauthorized` message, they might have a token that has expired and will need to run `terraform refresh` to get a new token.
Users of the `exec()` method should be aware that the `exec()` method is reliant on the awscli and the associated authtentication API version; the awscli version may need to be updated to support a later API version required by the Kubernetes version in use.

The following examples demonstrate either method that users can utilize - please refer to the associated provider's documentation for further details on cofiguration.

### Static Token Example

```hcl
provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks_blueprints.eks_cluster_id
}
```

### `exec()` Example

Usage of exec plugin for AWS credentials

Links to References related to this issue

- https://github.com/hashicorp/terraform/issues/29182
- https://github.com/aws/aws-cli/pull/6476

```hcl
provider "kubernetes" {
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks_blueprints.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
    }
  }
}

provider "kubectl" {
  apply_retry_count      = 10
  host                   = module.eks_blueprints.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_blueprints.eks_cluster_certificate_authority_data)
  load_config_file       = false

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks_blueprints.eks_cluster_id]
  }
}
```

### How to use IRSA module

Sample code snippet for using IRSA module directly

```hcl
module "irsa" {
    source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/irsa"
    kubernetes_namespace       = "<ENTER_NAMESPACE>"
    kubernetes_service_account = "<ENTER_SERVICE_ACCOUNT_NAME>"
    irsa_iam_policies          = ["<ENTER_IAM_POLICY_ARN>"]
    eks_cluster_id             = module.eks_blueprints.eks_cluster_id
    eks_oidc_provider_arn      = module.eks_blueprints.eks_oidc_provider_arn
}
```

### Upgrade requirements for EKS Cluster from v1.22 to v1.23

It's mandatory to deploy EBS CSI Driver from EKS Cluster v1.23 as it's not installed when you create a cluster.
For more details check this [link](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)

Ensure you deploy EBS CSI driver Add-on before upgrading your cluster from 1.22 to 1.23.

Enable the following add-on in EKS Cluster v1.22 and then upgrade to v1.23 to avoid any interruptions to your workload

```hcl
  enable_amazon_eks_aws_ebs_csi_driver = true
```
