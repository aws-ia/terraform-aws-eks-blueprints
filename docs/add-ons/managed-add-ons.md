# Amazon EKS Add-ons

[Amazon EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) provide installation and management of a curated set of add-ons for Amazon EKS clusters. All Amazon EKS add-ons include the latest security patches, bug fixes, and are validated by AWS to work with Amazon EKS. Amazon EKS add-ons allow you to consistently ensure that your Amazon EKS clusters are secure and stable and reduce the amount of work that you need to do in order to install, configure, and update add-ons.

EKS currently provides support for the following managed add-ons.

| Name | Description |
|------|-------------|
| [Amazon VPC CNI](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)  | Native VPC networking for Kubernetes pods. |
| [CoreDNS](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) | A flexible, extensible DNS server that can serve as the Kubernetes cluster DNS. |
| [kube-proxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) | Enables network communication to your pods. |
| [Amazon EBS CSI](https://docs.aws.amazon.com/eks/latest/userguide/managing-ebs-csi.html) | Manage the Amazon EBS CSI driver as an Amazon EKS add-on. |

EKS managed add-ons can be enabled via the following.

Note: EKS managed Add-ons can be converted to self-managed add-on with `preserve` field.
`preserve=true` option removes Amazon EKS management of any settings and the ability for Amazon EKS to notify you of updates and automatically update the Amazon EKS add-on after you initiate an update, but preserves the add-on's software on your cluster.
This option makes the add-on a self-managed add-on, rather than an Amazon EKS add-on.
There is no downtime while deleting EKS managed Add-ons when `preserve=true`. This is a default option for `enable_amazon_eks_vpc_cni` , `enable_amazon_eks_coredns` and `enable_amazon_eks_kube_proxy`.

Checkout this [doc](https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html#updating-vpc-cni-eks-add-on) for more details.

```
# EKS Addons
  enable_amazon_eks_vpc_cni = true # default is false
  #Optional
  amazon_eks_vpc_cni_config = {
    addon_name               = "vpc-cni"
    addon_version            = "v1.11.2-eksbuild.1"
    service_account          = "aws-node"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    preserve                 = true
    additional_iam_policies  = []
    tags                     = {}
  }

  enable_amazon_eks_coredns = true # default is false
  #Optional
  amazon_eks_coredns_config = {
    addon_name               = "coredns"
    addon_version            = "v1.8.4-eksbuild.1"
    service_account          = "coredns"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    preserve                 = true
    additional_iam_policies  = []
    tags                     = {}
  }

  enable_amazon_eks_kube_proxy = true # default is false
  #Optional
  amazon_eks_kube_proxy_config = {
    addon_name               = "kube-proxy"
    addon_version            = "v1.21.2-eksbuild.2"
    service_account          = "kube-proxy"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    service_account_role_arn = ""
    preserve                 = true
    additional_iam_policies  = []
    tags                     = {}
  }

  enable_amazon_eks_aws_ebs_csi_driver = true # default is false
  #Optional
  amazon_eks_aws_ebs_csi_driver_config = {
    addon_name               = "aws-ebs-csi-driver"
    addon_version            = "v1.4.0-eksbuild.preview"
    service_account          = "ebs-csi-controller-sa"
    resolve_conflicts        = "OVERWRITE"
    namespace                = "kube-system"
    additional_iam_policies  = []
    service_account_role_arn = ""
    tags                     = {}
  }
```

## Updating Managed Add-ons

EKS won't modify any of your Kubernetes add-ons when you update a cluster to a newer Kubernetes version. As a result, it is important to upgrade EKS add-ons each time you upgrade an EKS cluster.

Our [Cluster Upgrade](../advanced/cluster-upgrades.md) guide demonstrates how you can leverage this framework to upgrade your EKS cluster in addition to the EKS managed add-ons running in each cluster.

Additional information on updating a EKS cluster can be found in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).
