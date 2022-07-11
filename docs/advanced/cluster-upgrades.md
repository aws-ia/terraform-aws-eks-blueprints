### EKS Upgrade Documentation

#### Objective:

The purpose of this document is to provide an overview of the steps for upgrading the EKS Cluster from one version to another. Please note that EKS upgrade documentation gets published by AWS every year.

The current version of the upgrade documentation while writing this [README](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)

#### Prerequisites:

    1. Download the latest upgrade docs from AWS sites (https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
    2. Always upgrade one increment at a time (E.g., 1.20 to 1.21). AWS doesn't support upgrades from 1.20 to 1.22 directly

#### Steps to Upgrade EKS cluster:

1. Change the version in Terraform to the desired Kubernetes cluster version. See the example below

   ```hcl-terraform
   cluster_version      = "1.21"
   ```

2. If you are specifying a version for EKS managed addons, you will need to ensure the version used is compatible with the new cluster version, or use a data source to pull the appropriate version. If you are not specifying a version for EKS managed addons, no changes are required since the EKS service will update the default addon version based on the cluster version specified.

To ensure the correct addon version is used, it is recommended to use the addon version data source which will pull the appropriate version for a given cluster version:

```hcl-terraform
data "aws_eks_addon_version" "default" {
  for_each = toset(["coredns", "aws-ebs-csi-driver", "kube-proxy", "vpc-cni"])

  addon_name         = each.value
  kubernetes_version = "1.21" # ensure this matches whats set on the cluster
  most_recent        = false # can also set to `true` to use latest version for the specified cluster version
}

module "eks_blueprints_kubernetes_addons" {
  # Essential inputs are not shown for brevity

  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    addon_version            = data.aws_eks_addon_version.default["coredns"].version
    resolve_conflicts        = "OVERWRITE"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }

  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
    addon_version            = data.aws_eks_addon_version.default["aws-ebs-csi-driver"].version
    resolve_conflicts        = "OVERWRITE"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    addon_version            = data.aws_eks_addon_version.default["kube-proxy"].version
    resolve_conflicts        = "OVERWRITE"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    addon_version            = data.aws_eks_addon_version.default["vpc-cni"].version
    resolve_conflicts        = "OVERWRITE"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
}
```

3. Apply the changes to the cluster with Terraform. This will:
  - Upgrade the Control Plane to the version specified
  - Update the Data Plane to ensure the compute resources are utilizing the corresponding AMI for the given cluster version
  - Update addons to reflect the respective versions

## Important Note

Please note that you may need to update other Kubernetes Addons deployed through Helm Charts to match with new Kubernetes upgrade version
