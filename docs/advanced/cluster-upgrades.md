### EKS Upgrade Documentation

#### Objective:

The purpose of this document is to provide an overview of the steps for upgrading the EKS Cluster from one version to another. Please note that EKS upgrade documentation gets published by AWS every year.

The current version of the upgrade documentation while writing this [README](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)

#### Prerequisites:

    1. Download the latest upgrade docs from AWS sites (https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html)
    2. Always upgrade one increment at a time (E.g., 1.20 to 1.21). AWS doesn't support upgrades from 1.20 to 1.22 directly

#### Steps to upgrade EKS cluster:

 1. Change the version in Terraform to desired version under `base.tfvars`. See the example below

    ```hcl-terraform
    cluster_version      = "1.21"
    ```

2. Apply the changes to the cluster with Terraform. This step will upgrade the Control Plane and Data Plane to the newer version, and it will roughly take 35 mins to 1 hour

3. Once the Cluster is upgraded to desired version then please updated the following plugins as per the instructions

#### Steps to upgrade Add-ons:

Just update the latest versions from consumer module as shown below.
EKS Addon latest versions can be found in AWS EKS Console under Addon section or from AWS documentation.

##### KubeProxy

```hcl-terraform
  amazon_eks_kube_proxy_enable = true # default is false
  #Optional
  amazon_eks_kube_proxy_config = {
    addon_name               = "kube-proxy"
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
```

##### CoreDNS

```hcl-terraform
  amazon_eks_coredns_enable = true # default is false
  #Optional
  amazon_eks_coredns_config = {
    addon_name               = "coredns"
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    additional_iam_policies  = []
    tags                     = {}
  }
```

##### VPC CNI

```hcl-terraform
  amazon_eks_vpc_cni_enable = true
  amazon_eks_vpc_cni_config = {
    addon_name               = "vpc-cni"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
```

Apply the changes to the cluster with Terraform.

## Important Note

Please note that you may need to update other Kubernetes Addons deployed through Helm Charts to match with new Kubernetes upgrade version
