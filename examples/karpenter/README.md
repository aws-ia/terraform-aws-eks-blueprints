# Karpenter

This example demonstrates how to provision a Karpenter on a serverless cluster (serverless data plane) using Fargate Profiles.

This example solution provides:

- Amazon EKS Cluster (control plane)
- Amazon EKS Fargate Profiles for the `kube-system` namespace which is used by the `coredns`, `vpc-cni`, and `kube-proxy` addons, as well as profile that will match on the `karpenter` namespace which will be used by Karpenter.
- Amazon EKS managed addons `coredns`, `vpc-cni` and `kube-proxy`
    `coredns` has been patched to run on Fargate, and `vpc-cni` has been configured to use prefix delegation to better support the max pods setting of 110 on the Karpenter provisioner
- A sample deployment is provided to demonstrates scaling a deployment to view how Karpenter responds to provision, and de-provision, resources on-demand

## Prerequisites:

Ensure that you have the following tools installed locally:

1. [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
2. [kubectl](https://Kubernetes.io/docs/tasks/tools/)
3. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Deploy

To provision this example:

```sh
terraform init
terraform apply -target module.vpc
terraform apply -target module.eks
terraform apply
```

Enter `yes` at command prompt to apply

## Validate

The following command will update the `kubeconfig` on your local machine and allow you to interact with your EKS Cluster using `kubectl` to validate the CoreDNS deployment for Fargate.

1. Run `update-kubeconfig` command:

```sh
aws eks --region <REGION> update-kubeconfig --name <CLUSTER_NAME>
```

2. Test by listing all the pods running currently. The CoreDNS pod should reach a status of `Running` after approximately 60 seconds:

```sh
kubectl get pods -A

# Output should look like below
NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE
kube-system   coredns-66b965946d-gd59n              1/1     Running   0          92s
kube-system   coredns-66b965946d-tsjrm              1/1     Running   0          92s
kube-system   ebs-csi-controller-57cb869486-bcm9z   6/6     Running   0          90s
kube-system   ebs-csi-controller-57cb869486-xw4z4   6/6     Running   0          90s
```

3. View the current nodes - these should all be Fargate nodes at this point:

```sh
kubectl get nodes

# Output should look like below
NAME                                                STATUS   ROLES    AGE     VERSION
fargate-ip-10-0-10-11.us-west-2.compute.internal    Ready    <none>   8m7s    v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-210.us-west-2.compute.internal   Ready    <none>   2m50s   v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-218.us-west-2.compute.internal   Ready    <none>   8m6s    v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-227.us-west-2.compute.internal   Ready    <none>   8m8s    v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-42.us-west-2.compute.internal    Ready    <none>   8m6s    v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-71.us-west-2.compute.internal    Ready    <none>   2m48s   v1.24.8-eks-a1bebd3
```

4. Scale up the sample `pause` deployment to see Karpenter respond by provisioning nodes to support the workload:

```sh
kubectl scale deployment inflate --replicas 5
# To view logs
# kubectl logs -f -n karpenter -l app.kubernetes.io/name=karpenter -c controller
```

5. Re-check the nodes, you will now see a new EC2 node provisioned to support the scaled workload:

```sh
kubectl get nodes

# Output should look like below
NAME                                                STATUS   ROLES    AGE   VERSION
fargate-ip-10-0-10-11.us-west-2.compute.internal    Ready    <none>   18m   v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-210.us-west-2.compute.internal   Ready    <none>   13m   v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-218.us-west-2.compute.internal   Ready    <none>   18m   v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-227.us-west-2.compute.internal   Ready    <none>   18m   v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-42.us-west-2.compute.internal    Ready    <none>   18m   v1.24.8-eks-a1bebd3
fargate-ip-10-0-10-71.us-west-2.compute.internal    Ready    <none>   13m   v1.24.8-eks-a1bebd3
ip-10-0-11-62.us-west-2.compute.internal            Ready    <none>   35s   v1.24.7-eks-fb459a0 # <= new EC2 node launched
```

## Destroy

To teardown and remove the resources created in this example:

```sh
kubectl delete deployment inflate
terraform destroy -target="module.eks_blueprints_kubernetes_addons" -auto-approve
terraform destroy -target="module.eks" -auto-approve
terraform destroy -auto-approve
```
