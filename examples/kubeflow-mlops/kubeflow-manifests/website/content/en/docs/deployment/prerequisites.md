+++
title = "Prerequisites"
description = "Everything you need to get started with Kubeflow on AWS"
weight = 20
+++

## Install the necessary tools 
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) - A command line tool for interacting with AWS services.
- [eksctl](https://eksctl.io/introduction/#installation) - A command line tool for working with EKS clusters.
- [kubectl](https://kubernetes.io/docs/tasks/tools) - A command line tool for working with Kubernetes clusters.
- [yq](https://mikefarah.gitbook.io/yq) - A command line tool for YAML processing. (For Linux environments, use the [wget plain binary installation](https://github.com/mikefarah/yq/#install))
- [jq](https://stedolan.github.io/jq/download/) - A command line tool for processing JSON.
- [kustomize version 3.2.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/v3.2.0) - A command line tool to customize Kubernetes objects through a kustomization file.
> Warning: Kubeflow is not compatible with the latest versions of of kustomize 4.x. This is due to changes in the order that resources are sorted and printed. Please see [kubernetes-sigs/kustomize#3794](https://github.com/kubernetes-sigs/kustomize/issues/3794) and [kubeflow/manifests#1797](https://github.com/kubeflow/manifests/issues/1797). We know that this is not ideal and are working with the upstream kustomize team to add support for the latest versions of kustomize as soon as we can.
- [python 3.8+](https://www.python.org/downloads/) - A programming language used for automated installation scripts.
- [pip](https://pip.pypa.io/en/stable/installation/) - A package installer for python.
   
## Create an EKS cluster
> Note: Be sure to check [Amazon EKS and Kubeflow Compatibility]({{< ref "/docs/about/eks-compatibility.md" >}}) when creating your cluster with specific EKS versions.

If you do not have an existing cluster, run the following command to create an EKS cluster.

> Note: Various controllers use IAM roles for service accounts (IRSA). An [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) must exist for your cluster to use IRSA.

Change the values for the `CLUSTER_NAME` and `CLUSTER_REGION` environment variables: 
```bash
export CLUSTER_NAME=$CLUSTER_NAME
export CLUSTER_REGION=$CLUSTER_REGION
```

Run the following command to create an EKS cluster:
```bash
eksctl create cluster \
--name ${CLUSTER_NAME} \
--version 1.21 \
--region ${CLUSTER_REGION} \
--nodegroup-name linux-nodes \
--node-type m5.xlarge \
--nodes 5 \
--nodes-min 5 \
--nodes-max 10 \
--managed \
--with-oidc
```

If you are using an existing EKS cluster, create an [OIDC provider](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) and associate it with for your EKS cluster with the following command:
```bash
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} \
--region ${CLUSTER_REGION} --approve
```
More details about cluster creation via `eksctl` can be found in the [Creating and managing clusters](https://eksctl.io/usage/creating-and-managing-clusters/) guide.

## Clone the repository 
Clone the [`awslabs/kubeflow-manifests`](https://github.com/awslabs/kubeflow-manifests) and the [`kubeflow/manifests`](https://github.com/kubeflow/manifests) repositories and check out the release branches of your choosing.

Substitute the value for `KUBEFLOW_RELEASE_VERSION`(e.g. v1.5.1) and `AWS_RELEASE_VERSION`(e.g. v1.5.1-aws-b1.0.0) with the tag or branch you want to use below. Read more about [releases and versioning]({{< ref "/docs/about/releases.md" >}}) if you are unsure about what these values should be.
```bash
export KUBEFLOW_RELEASE_VERSION=<>
export AWS_RELEASE_VERSION=<>
git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
```
