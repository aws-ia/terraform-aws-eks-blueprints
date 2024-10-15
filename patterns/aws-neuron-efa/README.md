# EKS Cluster w/ AWS Neuron Devices and EFA for Machine Learning

This pattern demonstrates an Amazon EKS Cluster with an EFA-enabled nodegroup that utilizes `trn1.32xlarge` instances that are used in distributed, multi-node machine learning workloads.

The following components are demonstrated in this pattern:

- A "default" node group that supports addons and components that do not require AWS Neuron nor EFA devices. Any pods that do not tolerate the taints of the Neuron node group will be scheduled on instances within this node group.
- A node group of `trn1.32xlarge` instances with:
    - all x8 [EFA network interfaces](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/efa.html) enabled
    - provisioned within a placement group so that the instances are co-located close to one another in a single availability zone that supports the instance type
    - a common taint of `"aws.amazon.com/neuron:NoSchedule"` to ensure only the intended applications are permitted to run on the nodes created
    - two labels identifying that this nodegroup supports AWS Neuron and EFA devices; allowing pods to use node selectors with these labels
    - the NVME instance store volumes are mounted in a RAID-0 array to provide a single, large, high-performance storage volume for the Neuron workloads
    - kubelet and containerd are configured to utilize the RAID-0 volume, allowing kubelet to discover the additional storage as ephemeral storage that can be utilized by pods
- A Helm chart deployment for the [Neuron device plugin](https://github.com/aws-neuron/neuron-helm-charts/tree/main/charts/neuron-helm-chart) to expose and mount the Neuron devices provided by the instances to the pods that request them
- A Helm chart deployment for the EFA device plugin to expose and mount the EFA network interfaces provided by the instances to the pods that request them. Since the EFA network interfaces are only found on the instances that provide AWS Neuron devices in this pattern, we do not apply an additional taint for the EFA network interfaces to avoid over-constraining.

## Code

```terraform hl_lines="26-28 34-80"
{% include  "../../patterns/aws-neuron-efa/eks.tf" %}
```

```terraform hl_lines="9-50"
{% include  "../../patterns/aws-neuron-efa/helm.tf" %}
```

## Deploy

See [here](https://aws-ia.github.io/terraform-aws-eks-blueprints/getting-started/#prerequisites) for the prerequisites and steps to deploy this pattern.

## Validate

1. List the nodes and their instance type:

    ```sh
    kubectl get nodes -L node.kubernetes.io/instance-type
    ```

    ```text
    NAME                                        STATUS   ROLES    AGE   VERSION               INSTANCE-TYPE
    ip-10-0-12-200.us-east-2.compute.internal   Ready    <none>   82m   v1.31.0-eks-a737599   m5.large
    ip-10-0-24-248.us-east-2.compute.internal   Ready    <none>   82m   v1.31.0-eks-a737599   m5.large
    ip-10-0-39-213.us-east-2.compute.internal   Ready    <none>   75m   v1.31.0-eks-a737599   trn1.32xlarge
    ip-10-0-43-172.us-east-2.compute.internal   Ready    <none>   75m   v1.31.0-eks-a737599   trn1.32xlarge
    ```

    You should see two EFA-enabled (in this example `trn1.32xlarge`) nodes in the list.

## Destroy

{%
   include-markdown "../../docs/_partials/destroy.md"
%}
