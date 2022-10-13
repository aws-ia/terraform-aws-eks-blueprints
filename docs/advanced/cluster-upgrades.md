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
module "eks_blueprints_kubernetes_addons" {
  # Essential inputs are not shown for brevity

  enable_amazon_eks_coredns = true
  amazon_eks_coredns_config = {
    most_recent = true
  }

  enable_amazon_eks_aws_ebs_csi_driver = true
  amazon_eks_aws_ebs_csi_driver_config = {
    most_recent = true
  }

  enable_amazon_eks_kube_proxy = true
  amazon_eks_kube_proxy_config = {
    most_recent = true
  }

  enable_amazon_eks_vpc_cni = true
  amazon_eks_vpc_cni_config = {
    most_recent = true
  }
}
```

3. Apply the changes to the cluster with Terraform. This will:
  - Upgrade the Control Plane to the version specified
  - Update the Data Plane to ensure the compute resources are utilizing the corresponding AMI for the given cluster version
  - Update addons to reflect the respective versions

## Important Note

Please note that you may need to update other Kubernetes Addons deployed through Helm Charts to match with new Kubernetes upgrade version
