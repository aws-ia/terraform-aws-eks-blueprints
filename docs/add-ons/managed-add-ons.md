# Updating EKS Managed Add-ons

Amazon EKS doesn't modify any of your Kubernetes add-ons when you update a cluster to newer versions.

It's important to upgrade EKS Addons [Amazon VPC CNI](https://github.com/aws/amazon-vpc-cni-k8s), [DNS (CoreDNS)](https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html) and [KubeProxy](https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html) for each EKS release.

This [README](eks_cluster_addons_upgrade/README.md) guides you to update the EKS Cluster and the addons for newer versions that matches with your EKS cluster version

Updating a EKS cluster instructions can be found in [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html).