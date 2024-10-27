# Karpenter on EKS MNG

This pattern demonstrates how to provision Karpenter on an EKS managed node group. Deploying onto standard EC2 instances created by an EKS managed node group will allow for daemonsets to run on the nodes created for the Karpenter controller, and therefore better unification of tooling across your data plane. This solution is comprised of the following components:

1. An EKS managed node group that applies both a taint as well as a label for the Karpenter controller. We want the Karpenter controller to target these nodes via a `nodeSelector` in order to avoid the controller pods from running on nodes that Karpenter itself creates and manages. In addition, we are applying a taint to keep other pods off of these nodes as they are primarily intended for the controller pods. We apply a toleration to the CoreDNS addon, to allow those pods to run on the controller nodes as well. This is needed so that when a cluster is created, the CoreDNS pods have a place to run in order for the Karpenter controller to be provisioned and start managing the additional compute requirements for the cluster. Without letting CoreDNS run on these nodes, the controllers would fail to deploy and the data plane would be in a "deadlock" waiting for resources to deploy but unable to do so.
2. The `eks-pod-identity-agent` addon has been provisioned to allow the Karpenter controller to utilize EKS Pod Identity for AWS permissions via an IAM role.
3. The VPC subnets and node security group have been tagged with `"karpenter.sh/discovery" = local.name` for discoverability by the controller. The controller will discover these resources and use them to provision EC2 resources for the cluster.
4. An IAM role for the Karpenter controller has been created with a trust policy that trusts the EKS Pod Identity service principal. This allows the EKS Pod Identity service to provide AWS credentials to the Karpenter controller pods in order to call AWS APIs.
5. An IAM role for the nodes that Karpenter will create has been created along with a cluster access entry which allows the nodes to acquire permissions to join the cluster. Karpenter will create and manage the instance profile that utilizes this IAM role.
6. An SQS queue has been created that is subscribed to certain EC2 CloudWatch events. This queue is used by Karpenter, allowing it to respond to certain EC2 lifecycle events and gracefully migrate pods off the instance before it is terminated.

## Code

The areas of significance related to this pattern are highlighted in the code provided below.

### Cluster

```terraform hl_lines="20-28 47-50 52-60 64-69"
{% include  "../../patterns/karpenter-mng/eks.tf" %}
```

### Karpenter Resources

```terraform hl_lines="2 14-15 17-20 42-55"
{% include  "../../patterns/karpenter-mng/karpenter.tf" %}
```

```yaml hl_lines="9-17 28-29"
{% include  "../../patterns/karpenter-mng/karpenter.yaml" %}
```

### VPC

```terraform hl_lines="21-22"
{% include  "../../patterns/karpenter-mng/vpc.tf" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Test by listing the nodes in the cluster. You should see four Fargate nodes in the cluster:

    ```sh
    kubectl get nodes

    NAME                                        STATUS   ROLES    AGE     VERSION
    ip-10-0-23-32.us-west-2.compute.internal    Ready    <none>   10m     v1.30.4-eks-a737599
    ip-10-0-6-222.us-west-2.compute.internal    Ready    <none>   10m     v1.30.4-eks-a737599
    ```

2. Provision the Karpenter `EC2NodeClass` and `NodePool` resources which provide Karpenter the necessary configurations to provision EC2 resources:

    ```sh
    kubectl apply --server-side -f karpenter.yaml
    ```

3. Once the Karpenter resources are in place, Karpenter will provision the necessary EC2 resources to satisfy any pending pods in the scheduler's queue. You can demonstrate this with the example deployment provided. First deploy the example deployment which has the initial number replicas set to 0:

    ```sh
    kubectl apply --server-side -f example.yaml
    ```

4. When you scale the example deployment, you should see Karpenter respond by quickly provisioning EC2 resources to satisfy those pending pod requests:

    ```sh
    kubectl scale deployment inflate --replicas=3
    ```

5. Listing the nodes should now show some EC2 compute that Karpenter has created for the example deployment:

    ```sh
    kubectl get nodes

    NAME                                        STATUS   ROLES    AGE     VERSION
    ip-10-0-23-32.us-west-2.compute.internal    Ready    <none>   10m     v1.30.4-eks-a737599
    ip-10-0-46-239.us-west-2.compute.internal   Ready    <none>   20s     v1.30.1-eks-e564799 # <== EC2 created by Karpenter
    ip-10-0-6-222.us-west-2.compute.internal    Ready    <none>   10m     v1.30.4-eks-a737599
    ```

## Destroy

Scale down the deployment to de-provision Karpenter created resources first:

```sh
kubectl delete -f example.yaml
```

Remove the Karpenter Helm chart:

```sh
terraform destroy -target=helm_release.karpenter --auto-approve
```

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
