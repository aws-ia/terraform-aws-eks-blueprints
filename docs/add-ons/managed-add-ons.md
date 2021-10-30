# Amazon EKS Add-ons

[Amazon EKS add-ons](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html) provide installation and management of a curated set of add-ons for Amazon EKS clusters. All Amazon EKS add-ons include the latest security patches, bug fixes, and are validated by AWS to work with Amazon EKS. Amazon EKS add-ons allow you to consistently ensure that your Amazon EKS clusters are secure and stable and reduce the amount of work that you need to do in order to install, configure, and update add-ons.

EKS currently provides support for the following managed add-ons.

| Name | Description |
|------|-------------|
| [Amazon VPC CNI] | Native VPC networking for Kubernetes pods. |
| [CoreDNS] | A flexible, extensible DNS server that can serve as the Kubernetes cluster DNS. |
| [kube-proxy] | Enables network communication to your pods. |


EKS managed add-ons can be enabled via the following.

```
enable_vpc_cni_addon        = true
enable_coredns_addon        = true
enable_kube_proxy_addon     = true
```

## Updating Managed Add-ons

EKS won't modify any of your Kubernetes add-ons when you update a cluster to a newer Kubernetes version. As a result, it is important to upgrade EKS add-ons each time you upgrade an EKS cluster.

Our [Cluster Upgrade](../advanced/cluster-upgrades.md) guide demonstrates how you can leverage this framework to upgrade your EKS cluster in addition to the EKS managed add-ons running in each cluster.

Additional information on updating a EKS cluster can be found in the [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).

[Amazon VPC CNI]:(https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html)
[CoreDNS]:(https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html)
[kube-proxy]:(https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html)
