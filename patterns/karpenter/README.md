# Karpenter on EKS Fargate

This pattern demonstrates how to provision Karpenter on a serverless cluster (serverless data plane) using Fargate Profiles.

## Code

The areas of significance related to this pattern are highlighted in the code provided below.

### Cluster

```terraform hl_lines="18-19 28-31 34-38 42-45"
{% include  "../../patterns/karpenter/eks.tf" %}
```

### Karpenter Resources

```terraform hl_lines="2 14-15 17-19 21-24 46-55"
{% include  "../../patterns/karpenter/karpenter.tf" %}
```

```yaml hl_lines="9-17 28-29"
{% include  "../../patterns/karpenter/karpenter.yaml" %}
```

### VPC

```terraform hl_lines="21-22"
{% include  "../../patterns/karpenter/vpc.tf" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. Test by listing the nodes in the cluster. You should see two Fargate nodes in the cluster:

    ```sh
    kubectl get nodes

    NAME                                               STATUS   ROLES    AGE    VERSION
    fargate-ip-10-0-16-92.us-west-2.compute.internal   Ready    <none>   2m3s   v1.30.0-eks-404b9c6
    fargate-ip-10-0-8-95.us-west-2.compute.internal    Ready    <none>   2m3s   v1.30.0-eks-404b9c6
    ```

2. Before applying the Karpenter resources, you need to create the AWS Spot service-linked role. Run the following command:

    ```sh
    aws iam create-service-linked-role --aws-service-name spot.amazonaws.com
    ```

   This step is necessary to allow Karpenter to launch and manage Spot Instances.

3. Provision the Karpenter `EC2NodeClass` and `NodePool` resources which provide Karpenter the necessary configurations to provision EC2 resources:

    ```sh
    kubectl apply -f karpenter.yaml
    ```

4. Once the Karpenter resources are in place, Karpenter will provision the necessary EC2 resources to satisfy any pending pods in the scheduler's queue. You can demonstrate this with the example deployment provided. First deploy the example deployment which has the initial number replicas set to 0:

    ```sh
    kubectl apply -f example.yaml
    ```

5. When you scale the example deployment, you should see Karpenter respond by quickly provisioning EC2 resources to satisfy those pending pod requests:

    ```sh
    kubectl scale deployment inflate --replicas=3
    ```

6. Listing the nodes should now show some EC2 compute that Karpenter has created for the example deployment:

    ```sh
    kubectl get nodes

    NAME                                               STATUS   ROLES    AGE    VERSION
    fargate-ip-10-0-16-92.us-west-2.compute.internal   Ready    <none>   2m3s   v1.30.0-eks-404b9c6
    fargate-ip-10-0-8-95.us-west-2.compute.internal    Ready    <none>   2m3s   v1.30.0-eks-404b9c6
    ip-10-0-21-175.us-west-2.compute.internal          Ready    <none>   88s    v1.30.1-eks-e564799 # <== EC2 created by Karpenter
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
