# Fully Private Amazon EKS Cluster

This pattern demonstrates an Amazon EKS cluster that does not have internet access.
The private cluster must pull images from a container registry that is within in your VPC,
and also must have endpoint private access enabled. This is required for nodes
to register with the cluster endpoint.

Please see this [document](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html) for more details on configuring fully private EKS Clusters.

For fully Private EKS clusters requires the following VPC endpoints to be created to communicate with AWS services.
This example solution will provide these endpoints if you choose to create VPC.
If you are using an existing VPC then you may need to ensure these endpoints are created.

    com.amazonaws.region.aps-workspaces       - If using AWS Managed Prometheus Workspace
    com.amazonaws.region.ssm                  - Secrets Management
    com.amazonaws.region.ec2
    com.amazonaws.region.ecr.api
    com.amazonaws.region.ecr.dkr
    com.amazonaws.region.logs                 – For CloudWatch Logs
    com.amazonaws.region.sts                  – If using AWS Fargate or IAM roles for service accounts
    com.amazonaws.region.elasticloadbalancing – If using Application Load Balancers
    com.amazonaws.region.autoscaling          – If using Cluster Autoscaler
    com.amazonaws.region.s3

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Test by listing Nodes in in the cluster:

    ```sh
    kubectl get nodes
    ```

    ```text
    NAME                                        STATUS   ROLES    AGE     VERSION
    ip-10-0-19-90.us-west-2.compute.internal    Ready    <none>   8m34s   v1.26.2-eks-a59e1f0
    ip-10-0-44-110.us-west-2.compute.internal   Ready    <none>   8m36s   v1.26.2-eks-a59e1f0
    ip-10-0-9-147.us-west-2.compute.internal    Ready    <none>   8m35s   v1.26.2-eks-a59e1f0
    ```

2. Test by listing all the Pods running currently. All the Pods should reach a status of `Running` after approximately 60 seconds:

    ```sh
    kubectl get pods -A
    ```

    ```text
    NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
    kube-system   aws-node-jvn9x             1/1     Running   0          7m42s
    kube-system   aws-node-mnjlf             1/1     Running   0          7m45s
    kube-system   aws-node-q458h             1/1     Running   0          7m49s
    kube-system   coredns-6c45d94f67-495rr   1/1     Running   0          14m
    kube-system   coredns-6c45d94f67-5c8tc   1/1     Running   0          14m
    kube-system   kube-proxy-47wfh           1/1     Running   0          8m32s
    kube-system   kube-proxy-f6chz           1/1     Running   0          8m30s
    kube-system   kube-proxy-xcfkc           1/1     Running   0          8m31s
    ```

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
