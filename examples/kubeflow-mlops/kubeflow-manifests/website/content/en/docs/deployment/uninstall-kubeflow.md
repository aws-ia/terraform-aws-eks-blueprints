+++
title = "Uninstall Kubeflow"
description = "Delete Kubeflow deployments and Amazon EKS clusters"
weight = 80
+++

## Uninstall Kubeflow on AWS

First, delete all existing Kubeflow profiles. 

```bash
kubectl get profile
kubectl delete profile --all
```

You can delete a Kubeflow deployment by running the `kubectl delete` command on the manifest according to the deployment option you chose. For example, to delete a vanilla installation, run the following command:

```bash
kustomize build deployments/vanilla/ | kubectl delete -f -
```

This command assumes that you have the repository in the same state as when you installed Kubeflow.

Cleanup steps for specific deployment options can be found in their respective [installation guides]({{< ref "/docs/deployment" >}}). 

> Note: This will not delete your Amazon EKS cluster.

## (Optional) Delete Amazon EKS cluster

If you created a dedicated Amazon EKS cluster for Kubeflow using `eksctl`, you can delete it with the following command:

```bash
eksctl delete cluster --region $CLUSTER_REGION --name $CLUSTER_NAME
```

> Note: It is possible that parts of the CloudFormation deletion will fail depending upon modifications made post-creation. In that case, manually delete the eks-xxx role in IAM, then the ALB, the EKS target groups, and the subnets of that particular cluster. Then, retry the command to delete the nodegroups and the cluster.

For more detailed information on deletion options, see [Deleting an Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html). 